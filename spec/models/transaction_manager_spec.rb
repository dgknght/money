require 'spec_helper'

describe TransactionManager do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:checking) { FactoryGirl.create(:asset_account, name: "Checking", entity: entity) }
  let!(:salary) { FactoryGirl.create(:income_account, name: "Salary", entity: entity) }
  let (:transaction_attributes) do
    {
      transaction_date: Date.parse('2015-02-01'),
      description: 'Paycheck',
      items_attributes: [
        { account: checking, amount: 1_000, action: TransactionItem.debit },
        { account: salary,   amount: 1_000, action: TransactionItem.credit }
      ]
    }
  end
  shared_context :after_transactions do
    let!(:after_transaction) do
      TransactionManager.new(entity).create!(transaction_date: Date.parse('2015-03-01'),
                                             description: "Paycheck",
                                             items_attributes: [{ account_id: checking.id,
                                                                 action: TransactionItem.debit,
                                                                 amount: 1_000 },
                                                               { account_id: salary.id,
                                                                 action: TransactionItem.credit,
                                                                 amount: 1_000 }])
    end
  end
  shared_context :savings do
    let (:savings) { FactoryGirl.create(:asset_account, name: "Savings", entity: entity) }
    let!(:car) { FactoryGirl.create(:asset_account, name: "Car", entity: entity, parent: savings) }
    let!(:reserve) { FactoryGirl.create(:asset_account, name: "Reserve", entity: entity, parent: savings) }
    let!(:savings_transaction) do
      TransactionManager.new(entity).create!(transaction_date: Date.parse('2015-01-01'),
                                              description: "Bonus",
                                              items_attributes: [{ action: TransactionItem.credit,
                                                                  account_id: salary.id,
                                                                  amount: 1_000 },
                                                                { action: TransactionItem.debit,
                                                                  account_id: car.id,
                                                                  amount: 300 },
                                                                { action: TransactionItem.debit,
                                                                  account_id: reserve.id,
                                                                  amount: 700 }])
    end
  end

  describe '#create!' do
    it 'creates a new transaction record' do
      expect do
        TransactionManager.new(entity).create!(transaction_attributes)
      end.to change(Transaction, :count).by(1)
    end

    it 'returns the new transaction' do
      transaction = TransactionManager.new(entity).create!(transaction_attributes)
      expect(transaction).not_to be_nil
      expect(transaction.transaction_date).to eq(Date.parse('2015-02-01'))
      expect(transaction.description).to eq("Paycheck")
    end

    it 'sets the #balance of each item in the transaction' do
      transaction = TransactionManager.new(entity).create!(transaction_attributes)
      checking_item = transaction.items.select{|i| i.account_id = checking.id}.first
      expect(checking_item.balance).to eq(1_000)
    end

    it 'sets the #index of each item in the transaction' do
      transaction = TransactionManager.new(entity).create!(transaction_attributes)
      checking_item = transaction.items.select{|i| i.account_id = checking.id}.first
      expect(checking_item.index).to eq(0)
    end

    it 'updates the #balance of each referenced account' do
      expect do
        TransactionManager.new(entity).create!(transaction_attributes)
        checking.reload
      end.to change(checking, :balance).by(1_000)
    end

    context 'when accounts are nested' do
      include_context :savings

      it 'updates the #children-balance of each account in the parent chain of the referenced accounts' do
        expect do
          savings.reload
        end.to change(savings, :children_balance).by(1_000)
      end
    end

    context 'when later transactions exist' do
      include_context :after_transactions

      it 'updates the #balance of any transaction items after the items in the transaction' do
        TransactionManager.new(entity).create!(transaction_attributes)
        transaction = Transaction.where(transaction_date: Date.parse('2015-03-01')).first

        checking_item = transaction.items.where(account_id: checking.id).first
        expect(checking_item.balance).to eq(2_000)

        salary_item = transaction.items.where(account_id: salary.id).first
        expect(salary_item.balance).to eq(2_000)
      end

      it 'updates the #index of any transaction items after the items in the transaciton' do
        transaction = Transaction.where(transaction_date: Date.parse('2015-03-01')).first
        checking_item = transaction.items.where(account_id: checking.id).first
        expect do
          TransactionManager.new(entity).create!(transaction_attributes)
          checking_item.reload
        end.to change(checking_item, :index).by(1)
      end
    end
  end

  describe '#update!' do
    let!(:transaction) do
      TransactionManager.new(entity).create!(transaction_date: Date.parse('2015-02-01'),
                                             description: "Paycheck",
                                             items_attributes: [{ account_id: checking.id,
                                                                 action: TransactionItem.debit,
                                                                 amount: 1_000 },
                                                               { account_id: salary.id,
                                                                 action: TransactionItem.credit,
                                                                 amount: 1_000 }])
    end

    it 'does not create a new transaciton record' do
      expect do
        transaction.description = "Something else"
        TransactionManager.new(entity).update!(transaction)
      end.not_to change(Transaction, :count)
    end

    it 'saves the specified transaction' do
      transaction.description = "Something else"
      TransactionManager.new(entity).update!(transaction)
      fetched = Transaction.find(transaction.id)
      expect(fetched.description).to eq("Something else")
    end

    it 'saves the transaction items' do
      transaction.items.each{|i| i.amount = 1_001}
      TransactionManager.new(entity).update!(transaction)
      fetched = Transaction.find(transaction.id)
      fetched.items.each do |item|
        expect(item.amount).to eq(1_001)
      end
    end

    context 'with updated amounts' do
      it 'updates the #balance of the items in the transaction' do
        transaction.items.each{|i| i.amount = 1_234}
        salary_item = transaction.items.select{|i| i.account_id == salary.id}.first
        expect do
          TransactionManager.new(entity).update!(transaction)
          salary_item.reload
        end.to change(salary_item, :balance).by(234)
      end

      context 'when later items are present in the account' do
        include_context :after_transactions

        it 'updates the #balance of any items after the items in the transaction' do
          salary_item = after_transaction.items.where(account_id: salary.id).first
          transaction.items.each{|i| i.amount = 1_111}
          expect do
            TransactionManager.new(entity).update!(transaction)
            salary_item.reload
          end.to change(salary_item, :balance).by(111)
        end
      end

      it 'updates the #balance of all accounts referenced by the transaction items' do
        salary.reload #must reload after creating the transaction in the setup
        transaction.items.each{|i| i.amount = 1_100}
        expect do
          TransactionManager.new(entity).update!(transaction)
          salary.reload
        end.to change(salary, :balance).by(100)
      end

      context 'when nested accounts are present' do
        include_context :savings

        it 'updates the #children-balance of all accounts referened by the transaction items' do
          car_item = savings_transaction.items.select{|i| i.account_id == car.id}.first
          car_item.amount = 400
          salary_item = savings_transaction.items.select{|i| i.account_id == salary.id}.first
          salary_item.amount = 1_100

          savings.reload
          expect do
            TransactionManager.new(entity).update!(savings_transaction)
            savings.reload
          end.to change(savings, :children_balance).by(100)
        end
      end
    end

    context 'with an updated transaction date' do
      include_context :after_transactions

      it 'updates the #index of items in the transaction' do
        transaction.transaction_date = Date.parse('2015-04-01')
        salary_item = transaction.items.where(account_id: salary.id).first
        expect do
          TransactionManager.new(entity).update!(transaction)
          salary_item.reload
        end.to change(salary_item, :index).from(0).to(1)
      end

      it 'updates the #index of items that were after the updated transaction, but no longer are' do
        transaction.transaction_date = Date.parse('2015-04-01')
        salary_item = after_transaction.items.where(account_id: salary.id).first
        expect do
          TransactionManager.new(entity).update!(transaction)
          salary_item.reload
        end.to change(salary_item, :index).from(1).to(0)
      end

      it 'updates the #balance of items that were after the updated transaction, but no longer are' do
        transaction.transaction_date = Date.parse('2015-04-01')
        salary_item = after_transaction.items.where(account_id: salary.id).first
        expect do
          TransactionManager.new(entity).update!(transaction)
          salary_item.reload
        end.to change(salary_item, :balance).from(2_000).to(1_000)
      end

      it 'updates the #index of the items where were not after the updated transaction, but now are' do
        after_transaction.transaction_date = Date.parse('2015-01-01')
        salary_item = transaction.items.where(account_id: salary.id).first
        expect do
          TransactionManager.new(entity).update!(after_transaction)
          salary_item.reload
        end.to change(salary_item, :index).from(0).to(1)
      end

      it 'updates the #balance of the items where were not after the updated transaction, but now are' do
        after_transaction.transaction_date = Date.parse('2015-01-01')
        salary_item = transaction.items.where(account_id: salary.id).first
        expect do
          TransactionManager.new(entity).update!(after_transaction)
          salary_item.reload
        end.to change(salary_item, :balance).from(1_000).to(2_000)
      end
    end

    context 'with updated accounts' do
      it 'updates the following transactions in the old account'
      it 'updates the balance of the old account'
      it 'updates the children_balance values of parents of the old account'
    end

    context 'with deleted transaction items' do
      include_context :savings
      let!(:another_transaction) do
        TransactionManager.new(entity).create!(transaction_date: Date.parse('2015-06-01'),
                                               description: "Another bonus",
                                               items_attributes: [{action: TransactionItem.credit,
                                                                   account_id: salary.id,
                                                                   amount: 1_000},
                                                                  {action: TransactionItem.debit,
                                                                   account_id: car.id,
                                                                   amount: 1_000}])
      end

      it 'updates indexes for the following items' do
        to_delete = savings_transaction.items.select{|i| i.account_id == car.id}.first
        car_item = another_transaction.items(true).select{|i| i.account_id == car.id}.first
        expect do
          to_delete.destroy
          savings_transaction.items.select{|i| !i.destroyed?}.each{|i| i.amount = 1000}
          TransactionManager.new(entity).update!(savings_transaction)
          car_item.reload
        end.to change(car_item, :index).by(-1)
      end
    end
  end

  describe '#delete!' do
    let!(:t1) do
      TransactionManager.new(entity).create!(transaction_date: Date.parse('2015-01-01'),
                                             description: 'Paycheck',
                                             items_attributes: [{action: TransactionItem.credit,
                                                                 account_id: salary.id,
                                                                 amount: 999},
                                                                {action: TransactionItem.debit,
                                                                 account_id: checking.id,
                                                                 amount: 999}])
    end
    let!(:t2) do
      TransactionManager.new(entity).create!(transaction_date: Date.parse('2015-02-01'),
                                             description: 'Paycheck',
                                             items_attributes: [{action: TransactionItem.credit,
                                                                 account_id: salary.id,
                                                                 amount: 1_000},
                                                                {action: TransactionItem.debit,
                                                                 account_id: checking.id,
                                                                 amount: 1_000}])
    end

    it 'removes the transaction record from the system' do
      expect do
        TransactionManager.new(entity).delete!(t1)
      end.to change(Transaction, :count).by(-1)
    end

    it 'removes the transaction item records from the system' do
      expect do
        TransactionManager.new(entity).delete!(t1)
      end.to change(TransactionItem, :count).by(-2)
    end

    it 'updates the balance of the referenced accounts' do
      salary.reload
      expect do
        TransactionManager.new(entity).delete!(t1)
        salary.reload
      end.to change(salary, :balance).by(-999)
    end

    context 'when next accounts are present' do
      include_context :savings

      it 'updates the children_balance values of parents of the referenced accounts' do
        savings.reload
        expect do
          TransactionManager.new(entity).delete!(savings_transaction)
          savings.reload
        end.to change(savings, :children_balance).by(-1_000)
      end
    end
  end
end
