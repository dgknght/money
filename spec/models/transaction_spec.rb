require 'spec_helper'

describe Transaction do
  let(:checking) { FactoryGirl.create(:asset_account, name: 'Checking') }
  let(:groceries) { FactoryGirl.create(:expense_account, name: 'Groceries') }
  let(:entity) { FactoryGirl.create(:entity) }
  let(:attributes) do
    {
      transaction_date: Date.civil(2013, 1, 1),
      description: 'Kroger',
      entity_id: entity.id,
      items_attributes: [
        { account: checking, action: TransactionItem.credit, amount: 34.43 },
        { account: groceries, action: TransactionItem.debit, amount: 34.43 }
      ]
    }
  end
  let(:creating_a_transaction) { Transaction.create!(attributes) }
  
  it 'should be creatable from valid attributes' do
    transaction = Transaction.new(attributes)
    transaction.should be_valid
    transaction.should have(2).items
  end

  it 'should update the balance for the first referenced account' do
    expect do
      Transaction.create!(attributes)
    end.to change(checking, :balance).by(-34.43)
  end

  it 'should update the balance for the second (and remaining) referenced account' do
    expect do
      Transaction.create!(attributes)
    end.to change(groceries, :balance).by(34.43)
  end

  describe '#transaction_date' do
    it "should default to today's date" do
      transaction = Transaction.new(attributes.without(:transaction_date))
      transaction.should be_valid
      transaction.transaction_date.should == Date.today
    end
  end
  
  describe '#description' do
    it 'should be required' do
      transaction = Transaction.new(attributes.without(:description))
      transaction.should_not be_valid
    end
  end
  
  describe '#entity_id' do
    it 'should be required' do
      transaction = Transaction.new(attributes.without(:entity_id))
      transaction.should_not be_valid
    end
  end
  
  describe '#items' do
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

  describe '#attachments' do
    let (:transaction) { FactoryGirl.create(:transaction) }

    it 'should contain a list of attachments for the transaction' do
      expect(transaction).to have(0).attachments
    end
  end

  describe '#lot_transactions' do
    it 'should list the lot transactions for the instance' do
      transaction = Transaction.new(attributes)
      expect(transaction.lot_transactions).to be_empty
    end
  end

  describe '#destroy' do
    let!(:transaction) { FactoryGirl.create(:transaction) }

    it 'should remove all transaction items for the transaction' do
      expect{transaction.destroy!}.to change(TransactionItem, :count).by(-2)
    end
  end
end
