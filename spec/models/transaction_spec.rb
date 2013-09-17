require 'spec_helper'

describe Transaction do
  let(:attributes) do
    {
      transaction_date: Date.civil(2013, 1, 1),
      description: 'Kroger'
    }
  end
  
  it 'should be creatable from valid attributes' do
    transaction = Transaction.new(attributes)
    transaction.should be_valid
  end
  
  describe 'transaction_date' do
    it "should default to today's date" do
      transaction = Transaction.new(attributes.without(:transaction_date))
      transaction.should be_valid
      transaction.transaction_date.should == Date.today
    end
  end
  
  describe 'description' do
    it 'should be required' do
      transaction = Transaction.new(attributes.without(:description))
      transaction.should_not be_valid
    end
  end
  
  describe 'items' do
    let(:transaction) { FactoryGirl.create(:transaction) }
    let(:checking) { FactoryGirl.create(:asset_account, name: 'Checking') }
    let(:groceries) { FactoryGirl.create(:expense_account, name: 'Groceries') }
    
    it 'should contain a list of transaction items' do
      transaction.should respond_to :items
    end
    
    it 'should have a sum of credits equal to the sum of debits' do
      transaction.items.create(account: checking, action: :debit, amount: 56.65)
      transaction.should_not be_valid
      
      transaction.items.create(account: groceries, action: :credit, amount: 56.65)
      transaction.should be_valid
    end
  end
end