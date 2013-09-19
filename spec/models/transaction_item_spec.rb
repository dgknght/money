require 'spec_helper'

describe TransactionItem do
  let (:checking) { FactoryGirl.create(:asset_account, name: 'Checking') }
  let!(:transaction) { FactoryGirl.create(:transaction) }
  let (:attributes) do
    {
      transaction: transaction,
      account: checking,
      action: :credit,
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
      item = TransactionItem.new(attributes.merge(action: :debit))
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
  
  describe 'credits' do
    it 'should return the transaction items with the :credit action' do
      TransactionItem.should have(1).credit # added by the factory
    end
  end
  
  describe 'debits' do
    it 'should return the transaction items with the :debit action' do
      TransactionItem.should have(1).debit # added by the factory
    end
  end
end
