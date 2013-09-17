require 'spec_helper'

describe TransactionItem do
  let(:checking) { FactoryGirl.create(:asset_account, name: 'Checking') }
  let(:transaction) { FactoryGirl.create(:transaction) }
  let(:attributes) do
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
    let!(:credit1) { FactoryGirl.create(:transaction_item, transaction: transaction, action: :credit) }
    let!(:credit2) { FactoryGirl.create(:transaction_item, transaction: transaction, action: :credit) }
    let!(:debit) { FactoryGirl.create(:transaction_item, transaction: transaction, action: :debit) }
    
    it 'should return the transaction items with the :credit action' do
      TransactionItem.credits.should == [credit1, credit2]
    end
  end
  
  describe 'credits' do
    let!(:credit1) { FactoryGirl.create(:transaction_item, transaction: transaction, action: :credit) }
    let!(:debit1) { FactoryGirl.create(:transaction_item, transaction: transaction, action: :debit) }
    let!(:debit2) { FactoryGirl.create(:transaction_item, transaction: transaction, action: :debit) }
    
    it 'should return the transaction items with the :credit action' do
      TransactionItem.debits.should == [debit1, debit2]
    end
  end
end
