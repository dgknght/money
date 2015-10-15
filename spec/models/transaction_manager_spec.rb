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
      expect(checking_item.index).to eq(1)
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

  describe '#update' do
    it 'does not create a new transaciton record'
    it 'saves the specified transaction'
    it 'saves the transaction items'
    context 'with updated amounts' do
      it 'updates the #balance of the items in the transaction'
      it 'updates the #balance of any items after the items in the transaction'
      it 'updates the #balance of all accounts referenced by the transaction items'
      it 'updates the #children-balance of all accounts referened by the transaction items'
    end
    context 'with an updated transaction date' do
      it 'updates the #index of items in the transaction'
    end
  end
end
