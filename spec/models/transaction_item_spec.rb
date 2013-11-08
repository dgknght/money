require 'spec_helper'

describe TransactionItem do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity, name: 'Groceries') }
  let (:gasoline) { FactoryGirl.create(:expense_account, entity: entity, name: 'Gasoline') }
  let (:transaction) { FactoryGirl.create(:transaction, entity: entity) }
  let (:attributes) do
    {
      transaction: transaction,
      account: checking,
      action: TransactionItem.credit,
      amount: 100.00
    }
  end
  
  it 'should be creatable from valid attributes' do
    item = TransactionItem.new(attributes)
    item.should be_valid
  end
  
  describe 'transaction' do
    it 'should be required' do
      item = TransactionItem.new(attributes.without(:transaction))
      item.should_not be_valid
    end
  end
  
  describe 'account' do
    it 'should be required' do
      item = TransactionItem.new(attributes.without(:account))
      item.should_not be_valid
    end
  end
  
  describe 'action' do
    it 'should be required' do
      item = TransactionItem.new(attributes.without(:action))
      item.should_not be_valid
    end
    
    it 'should allow only :credit or :debit' do
      item = TransactionItem.new(attributes.merge(action: TransactionItem.debit))
      item.should be_valid
      
      item.action = :something_else
      item.should_not be_valid
    end
  end
  
  describe 'amount' do
    it 'should be required' do
      item = TransactionItem.new(attributes.without(:amount))
      item.should_not be_valid
    end
  end
  
  describe 'polarized_amount' do
    let (:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'Credit card') }
    let (:credit_card) { FactoryGirl.create(:liability_account, entity: entity, name: 'Credit card') }
    let (:opening_balances) { FactoryGirl.create(:equity_account, entity: entity, name: 'Credit card') }
    context 'with a credit action' do
      let (:action) { TransactionItem.credit }
      it 'should return a negative value for an asset account' do
        item = TransactionItem.new(attributes.merge(account: checking, action: action))
        item.polarized_amount.to_i.should == -100
      end
      
      it 'should return a positive value for a liability account' do
        item = TransactionItem.new(attributes.merge(account: credit_card, action: action))
        item.polarized_amount.to_i.should == 100
      end
      
      it 'should return a positive value for an equity account' do
        item = TransactionItem.new(attributes.merge(account: opening_balances, action: action))
        item.polarized_amount.to_i.should == 100
      end
      
      it 'should return a positive value for an income account' do
        item = TransactionItem.new(attributes.merge(account: salary, action: action))
        item.polarized_amount.to_i.should == 100
      end      
      
      it 'should return a negative value for an expense account' do
        item = TransactionItem.new(attributes.merge(account: groceries, action: action))
        item.polarized_amount.to_i.should == -100
      end      
    end
    
    context 'with a debit action' do
      let (:action) { TransactionItem.debit }
      it 'should return a positive value for an asset account' do
        item = TransactionItem.new(attributes.merge(account: checking, action: action))
        item.polarized_amount.to_i.should == 100
      end
      
      it 'should return a negative value for a liability account' do
        item = TransactionItem.new(attributes.merge(account: credit_card, action: action))
        item.polarized_amount.to_i.should == -100
      end
      
      it 'should return a negative value for an equity account' do
        item = TransactionItem.new(attributes.merge(account: opening_balances, action: action))
        item.polarized_amount.to_i.should == -100
      end
      
      it 'should return a negative value for an income account' do
        item = TransactionItem.new(attributes.merge(account: salary, action: action))
        item.polarized_amount.to_i.should == -100
      end      
      
      it 'should return a positive value for an expense account' do
        item = TransactionItem.new(attributes.merge(account: groceries, action: action))
        item.polarized_amount.to_i.should == 100
      end      
    end
  end
  
  describe 'credits' do
    it 'should return the transaction items with the :credit action' do
      TransactionItem.credits.where(action: TransactionItem.debit).should_not be_any
    end
  end
  
  describe 'debits' do
    it 'should return the transaction items with the :debit action' do
      TransactionItem.debits.where(action: TransactionItem.credit).should_not be_any
    end
  end
  
  describe 'after create' do    
    it 'should update the balance on the referenced account' do
      transaction = entity.transactions.new(description: 'Kroger')
      transaction.items.build(account: checking, action: TransactionItem.credit, amount: 100)
      transaction.items.build(account: groceries, action: TransactionItem.debit, amount: 100)
      transaction.save!
      
      checking.balance.to_i.should == -100
      groceries.balance.to_i.should == 100
    end
  end
  
  describe 'after update' do
    it 'should adjust the balance of the referenced account' do
      transaction = entity.transactions.new(description: 'Kroger')
      transaction.items.build(account: checking, action: TransactionItem.credit, amount: 100)
      transaction.items.build(account: groceries, action: TransactionItem.debit, amount: 100)
      transaction.save!
      
      checking.balance.to_i.should == -100
      groceries.balance.to_i.should == 100
      
      transaction.items.each { |i| i.amount = 101 }
      transaction.save!
      
      checking.reload
      groceries.reload
      
      checking.balance.to_i.should == -101
      groceries.balance.to_i.should == 101
    end
  end
  
  describe 'after update with account changed' do
    it 'should adjust the balance of the referenced account' do
      transaction = entity.transactions.new(description: 'Kroger')
      checking_item = transaction.items.build(account: checking, action: TransactionItem.credit, amount: 100)
      groceries_item = transaction.items.build(account: groceries, action: TransactionItem.debit, amount: 100)
      transaction.save!
      
      checking.balance.to_i.should == -100
      groceries.balance.to_i.should == 100

      groceries_item.account = gasoline
      transaction.save!
      groceries.reload
      gasoline.reload
      
      checking.balance.to_i.should == -100
      groceries.balance.to_i.should == 0
      gasoline.balance.to_i.should == 100
    end
  end
  
  describe 'after destroy' do
    it 'should adjust the balance of the referenced account' do
      transaction = entity.transactions.new(description: 'Kroger')
      transaction.items.build(account: checking, action: TransactionItem.credit, amount: 100)
      transaction.items.build(account: groceries, action: TransactionItem.debit, amount: 100)
      transaction.save!
      
      checking.balance.to_i.should == -100
      groceries.balance.to_i.should == 100

      groceries_item = transaction.items.select{ |item| item.account.id == groceries.id }.first
      groceries_item.destroy
      transaction.items.build(account: gasoline, action: TransactionItem.debit, amount: 100)
      transaction.should be_valid
      transaction.save!
      groceries.reload
      
      checking.balance.to_i.should == -100
      groceries.balance.to_i.should == 0
      gasoline.balance.to_i.should == 100
    end
  end
end
