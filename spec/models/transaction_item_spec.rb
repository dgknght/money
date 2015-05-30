require 'spec_helper'

describe TransactionItem do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity, name: 'Groceries') }
  let (:gasoline) { FactoryGirl.create(:expense_account, entity: entity, name: 'Gasoline') }
  let (:transaction) { FactoryGirl.create(:transaction, entity: entity) }
  let (:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'Credit card') }
  let (:credit_card) { FactoryGirl.create(:liability_account, entity: entity, name: 'Credit card') }
  let (:opening_balances) { FactoryGirl.create(:equity_account, entity: entity, name: 'Opening balances') }
  let (:attributes) do
    {
      transaction: transaction,
      account: checking,
      action: TransactionItem.credit,
      memo: "dinner party food",
      confirmation: '123F',
      amount: 100.00
    }
  end
  
  it 'should be creatable from valid attributes' do
    item = TransactionItem.new(attributes)
    expect(item).to be_valid
  end
  
  describe '#transaction' do
    it 'should be required' do
      item = TransactionItem.new(attributes.without(:transaction))
      expect(item).not_to be_valid
    end
    
    it 'should refer to the transaction to which the item belongs' do
      item = TransactionItem.new(attributes)
      expect(item.transaction_id).to eq(transaction.id)
    end
  end
  
  describe '#account' do
    it 'should be required' do
      item = TransactionItem.new(attributes.without(:account))
      expect(item).not_to be_valid
    end
  end
  
  describe '#action' do
    it 'should be required' do
      item = TransactionItem.new(attributes.without(:action))
      expect(item).not_to be_valid
    end
    
    it 'should allow only :credit or :debit' do
      item = TransactionItem.new(attributes.merge(action: TransactionItem.debit))
      expect(item).to be_valid
      
      item.action = :something_else
      expect(item).not_to be_valid
    end
  end
  
  describe '#amount' do
    it 'should be required' do
      item = TransactionItem.new(attributes.without(:amount))
      expect(item).not_to be_valid
    end
  end
  
  describe '#polarized_amount' do
    context 'with a credit action' do
      let (:action) { TransactionItem.credit }
      it 'should return a negative value for an asset account' do
        item = TransactionItem.new(attributes.merge(account: checking, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end
      
      it 'should return a positive value for a liability account' do
        item = TransactionItem.new(attributes.merge(account: credit_card, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end
      
      it 'should return a positive value for an equity account' do
        item = TransactionItem.new(attributes.merge(account: opening_balances, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end
      
      it 'should return a positive value for an income account' do
        item = TransactionItem.new(attributes.merge(account: salary, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end      
      
      it 'should return a negative value for an expense account' do
        item = TransactionItem.new(attributes.merge(account: groceries, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end      
    end
    
    context 'with a debit action' do
      let (:action) { TransactionItem.debit }
      it 'should return a positive value for an asset account' do
        item = TransactionItem.new(attributes.merge(account: checking, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end
      
      it 'should return a negative value for a liability account' do
        item = TransactionItem.new(attributes.merge(account: credit_card, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end
      
      it 'should return a negative value for an equity account' do
        item = TransactionItem.new(attributes.merge(account: opening_balances, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end
      
      it 'should return a negative value for an income account' do
        item = TransactionItem.new(attributes.merge(account: salary, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end      
      
      it 'should return a positive value for an expense account' do
        item = TransactionItem.new(attributes.merge(account: groceries, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end      
    end
  end
  
  describe '::credits' do
    it 'should return the transaction items with the :credit action' do
      expect(TransactionItem.credits.where(action: TransactionItem.debit)).to be_empty
    end
  end
  
  describe '::debits' do
    it 'should return the transaction items with the :debit action' do
      expect(TransactionItem.debits.where(action: TransactionItem.credit)).to be_empty
    end
  end
  
  shared_context 'buy groceries' do
    let!(:trn){FactoryGirl.create(:transaction, debit_account: groceries, credit_account: checking, amount: 100)}
  end

  describe 'after create' do    
    include_context 'buy groceries'

    it 'should update the balance on the referenced account' do
      expect(checking.balance.to_i).to eq(-100)
      expect(groceries.balance.to_i).to eq(100)
    end
  end
  
  describe 'after update' do
    include_context 'buy groceries'

    it 'should adjust the balance of the referenced account' do
      expect(checking.balance.to_i).to eq(-100)
      expect(groceries.balance.to_i).to eq(100)
      
      trn.items.each { |i| i.amount = 101 }
      trn.save!
      
      checking.reload
      groceries.reload
      
      expect(checking.balance.to_i).to eq(-101)
      expect(groceries.balance.to_i).to eq(101)
    end
  end
  
  describe 'after update with account changed' do
    include_context 'buy groceries'

    it 'should adjust the balance of the referenced account' do
      expect(checking.balance.to_i).to eq(-100)
      expect(groceries.balance.to_i).to eq(100)

      groceries_item = trn.items.select{|i| i.account.id == groceries.id}.first
      groceries_item.account = gasoline
      trn.save!
      groceries.reload
      gasoline.reload
      
      expect(checking.balance.to_i).to eq(-100)
      expect(groceries.balance.to_i).to be_zero
      expect(gasoline.balance.to_i).to eq(100)
    end
  end
  
  describe 'after destroy' do
    include_context 'buy groceries'

    it 'should adjust the balance of the referenced account' do
      expect(checking.balance.to_i).to eq(-100)
      expect(groceries.balance.to_i).to eq(100)

      groceries_item = transaction.items.select{ |item| item.account.id == groceries.id }.first
      groceries_item.destroy
      trn.items.build(account: gasoline, action: TransactionItem.debit, amount: 100)
      expect(trn).to be_valid
      trn.save!
      groceries.reload
      
      expect(checking.balance.to_i).to eq(-100)
      expect(groceries.balance.to_i).to be_zero
      expect(gasoline.balance.to_i).to eq(100)
    end
  end
  
  describe '#reconciled?' do
    it 'should default to false' do
      item = TransactionItem.new(attributes)
      expect(item).not_to be_reconciled
    end    
  end
  
  context 'when reconciled' do
    let (:reconciled) { FactoryGirl.create(:transaction_item, reconciled: true) }
    it 'cannot be deleted' do
      expect { reconciled.destroy }.to raise_error(Money::CannotDeleteError)
    end
  end
  
  describe '#balance' do
    let (:t1) do
      FactoryGirl.create(:transaction, transaction_date: '2015-01-15',
                                       amount: 2_000,
                                       credit_account: salary,
                                       debit_account: checking)
    end
    let (:t2) do
      FactoryGirl.create(:transaction, transaction_date: '2015-01-01',
                                       amount: 999,
                                       credit_account: opening_balances,
                                       debit_account: checking)
    end

    it 'contains the balance of the account as a result of the inclusion if the transaction item' do
      checking_item = t1.items.select{|i| i.account.id == checking.id}.first
      expect(checking_item.balance.to_f).to eq(2_000)

      ob_item = t1.items.select{|i| i.account.id == salary.id}.first
      expect(ob_item.balance.to_f).to eq(2_000)
    end

    it 'is recalculated if any transaction items are inserted earlier in the account history' do
      c1 = t1.items.select{|i| i.account_id == checking.id}.first
      expect(c1.balance.to_f).to eq(2_000)
      c2 = t2.items.select{|i| i.account_id == checking.id}.first
      expect(c2.balance.to_f).to eq(999)
      c1.reload
      expect(c1.balance.to_f).to eq(2_999)
    end
  end

  describe '#unreconciled scope' do
    let!(:unreconciled) { FactoryGirl.create(:transaction_item) }
    let!(:reconciled) { FactoryGirl.create(:transaction_item, reconciled: true) }
    
    it 'should return the unreconciled transaction items' do
      expect(TransactionItem.unreconciled).not_to include(reconciled)
      expect(TransactionItem.unreconciled).to include(unreconciled)
    end
  end
  
  describe '#reconciled scope' do
    let!(:unreconciled) { FactoryGirl.create(:transaction_item) }
    let!(:reconciled) { FactoryGirl.create(:transaction_item, reconciled: true) }
    
    it 'should return the reconciled transaction items' do
      expect(TransactionItem.reconciled).to include(reconciled)
      expect(TransactionItem.reconciled).not_to include(unreconciled)
    end
  end

  describe '::opposite_action' do
    it 'should return debit when give credit' do
      result = TransactionItem.opposite_action(TransactionItem.credit)
      expect(result).to eq(TransactionItem.debit)
    end

    it 'should return credit when give debit' do
      result = TransactionItem.opposite_action(TransactionItem.debit)
      expect(result).to eq(TransactionItem.credit)
    end
  end
end
