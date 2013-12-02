require 'spec_helper'

describe TransactionItemCreator do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity, name: 'Groceries') }
  let (:transaction) { FactoryGirl.create(:transaction, transaction_date: '2013-02-27', description: 'Kroger', debit_account: groceries, credit_account: checking, amount: 25) }
  let (:transaction_item) { transaction.items.select{ |i| i.account_id == checking.id }.first }
  let (:attributes) do
    {
      transaction_date: '2013-01-01',
      description: 'Market Street',
      other_account_id: groceries.id,
      amount: 100
    }
  end
  
  it 'should be creatable with an account' do
    creator = TransactionItemCreator.new(checking)
    creator.should_not be_nil
  end
  
  it 'should be creatable with an account and valid attributes' do
    creator = TransactionItemCreator.new(checking, attributes)
    creator.should be_valid
  end
  
  describe 'transaction_date' do
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:transaction_date))
      creator.should have(1).error_on(:transaction_date)
    end
    
    it 'should be a date, or a date-parsable string' do
      creator = TransactionItemCreator.new(checking, attributes)
      creator.transaction_date.should == Date.civil(2013, 1, 1)
    end
  end
  
  describe 'description' do
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:description))
      creator.should have(1).error_on(:description)
    end
  end
  
  describe 'other_account_id' do
    let (:invalid_account) { FactoryGirl.create(:account) }
    
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:other_account_id))
      creator.should have(1).error_on(:other_account_id)
    end
    
    it 'should belong to the same entity as the creating account' do
      creator = TransactionItemCreator.new(checking, attributes.merge(other_account_id: invalid_account.id))
      creator.should have(1).error_on(:other_account_id)
    end
  end
  
  describe 'amount' do
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:amount))
      creator.should have(1).error_on(:amount)
    end
  end
  
  
  describe 'create' do
    it 'should create a new transaction item with valid attributes' do
      creator = TransactionItemCreator.new(checking, attributes)
      item = creator.create
      item.should_not be_nil
      item.should respond_to :account
      item.account.should == checking
      item.should respond_to :amount
      item.amount.should == 100
      item.should respond_to :action
      item.action.should == TransactionItem.credit
      item.should respond_to :transaction
      item.transaction.should respond_to :transaction_date
      item.transaction.transaction_date.should == Date.civil(2013, 1, 1)
      item.transaction.should respond_to :description
      item.transaction.description.should == 'Market Street'
    end
    
    it 'should return null with invalid attributes' do
      creator = TransactionItemCreator.new(checking, attributes.without(:description))
      creator.create.should be_nil
    end
  end
  
  describe 'create!' do
    it 'should create a new transaction item with valid attributes' do
      creator = TransactionItemCreator.new(checking, attributes)
      item = creator.create!
      item.should_not be_nil
      item.should respond_to :account
      item.account.should == checking
      item.should respond_to :amount
      item.amount.should == 100
      item.should respond_to :action
      item.action.should == TransactionItem.credit
      item.should respond_to :transaction
      item.transaction.should respond_to :transaction_date
      item.transaction.transaction_date.should == Date.civil(2013, 1, 1)
      item.transaction.should respond_to :description
      item.transaction.description.should == 'Market Street'
    end
    
    it 'should raise InvalidStateError with invalid attributes' do
      creator = TransactionItemCreator.new(checking, attributes.without(:description))
      expect { creator.create! }.to raise_error(Money::InvalidStateError)
    end
  end
  
  describe 'update' do
    it 'should return true for success' do
      creator = TransactionItemCreator.new(transaction_item, attributes)
      creator.update.should be_true
    end
    
    it 'should update the specified transaction with the specified description' do
      creator = TransactionItemCreator.new(transaction_item, attributes)
      expect do
        creator.update
        transaction.reload
      end.to change(transaction, :description).from('Kroger').to('Market Street')
    end
    
    it 'should update the specified transaction with the specified transaction date' do
      creator = TransactionItemCreator.new(transaction_item, attributes)
      expect do
        creator.update
        transaction.reload
      end.to change(transaction, :transaction_date).from(Date.parse('2013-02-27')).to(Date.parse('2013-01-01'))
    end
    
    it 'should update the specified transaction item with the specified amount' do
      creator = TransactionItemCreator.new(transaction_item, attributes)
      expect do
        creator.update
        transaction_item.reload
      end.to change(transaction_item, :amount).from(BigDecimal.new(25)).to(BigDecimal.new(100))
    end
  end
end