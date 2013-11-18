require 'spec_helper'

describe TransactionItemCreator do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity, name: 'Groceries') }
  let (:attributes) do
    {
      transaction_date: '2013-11-18',
      description: 'Market Street',
      other_account: groceries,
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
      creator.transaction_date.should == Date.civil(2013, 11, 18)
    end
  end
  
  describe 'description' do
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:description))
      creator.should_not be_valid
    end
  end
  
  describe 'other_account' do
    it 'should be required'
    it 'should be an account'
    it 'should belong to the same entity as the creating account'
  end
  
  describe 'amount' do
    it 'should be required'
    it 'should be numeric'
  end
end