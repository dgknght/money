require 'spec_helper'

describe Transaction do
  let(:checking) { FactoryGirl.create(:asset_account, name: 'Checking', balance: 100) }
  let(:groceries) { FactoryGirl.create(:expense_account, name: 'Groceries', balance: 0) }
  let(:user) { FactoryGirl.create(:user) }
  let(:attributes) do
    {
      transaction_date: Date.civil(2013, 1, 1),
      description: 'Kroger',
      user_id: user.id,
      items_attributes: [
        { account: checking, action: TransactionItem.credit, amount: 34.43 },
        { account: groceries, action: TransactionItem.debit, amount: 34.43 }
      ]
    }
  end
  
  it 'should be creatable from valid attributes' do
    transaction = Transaction.new(attributes)
    transaction.should be_valid
    transaction.should have(2).items
  end

  it 'should update the balance for all referenced accounts' do
    checking.balance.should == 100
    groceries.balance.should == 0
    transaction = Transaction.create!(attributes)
    
    checking.balance.should == BigDecimal.new('65.57')
    groceries.balance.should ==  BigDecimal.new('34.43')    
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
  
  describe 'user_id' do
    it 'should be required' do
      transaction = Transaction.new(attributes.without(:user_id))
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
      transaction.items.create(account: checking, action: TransactionItem.debit, amount: 56.65)
      transaction.should_not be_valid
      
      transaction.items.create(account: groceries, action: TransactionItem.credit, amount: 56.65)
      transaction.should be_valid
    end
    
    it 'should have content in order to be valid' do
      transaction = Transaction.new(attributes.without(:items_attributes))
      transaction.should_not be_valid
    end
  end
end
