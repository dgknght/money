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
  
  it 'is creatable from valid attributes' do
    transaction = Transaction.new(attributes)
    expect(transaction).to be_valid
    expect(transaction).to have(2).items
  end

  describe '#transaction_date' do
    it "should default to today's date" do
      transaction = Transaction.new(attributes.without(:transaction_date))
      expect(transaction).to be_valid
      expect(transaction.transaction_date).to eq(Date.today)
    end
  end
  
  describe '#description' do
    it 'is required' do
      transaction = Transaction.new(attributes.without(:description))
      expect(transaction).to_not be_valid
    end
  end
  
  describe '#entity_id' do
    it 'is required' do
      transaction = Transaction.new(attributes.without(:entity_id))
      expect(transaction).to_not be_valid
    end
  end
  
  describe '#items' do
    let(:transaction) { FactoryGirl.create(:transaction) }
    let(:checking) { FactoryGirl.create(:asset_account, name: 'Checking') }
    let(:groceries) { FactoryGirl.create(:expense_account, name: 'Groceries') }
    
    it 'contains a list of transaction items' do
      expect(transaction).to respond_to :items
    end
    
    it 'has a sum of credits equal to the sum of debits' do
      transaction.items.create(account: checking, action: TransactionItem.debit, amount: 56.65)
      expect(transaction).to_not be_valid
      
      transaction.items.create(account: groceries, action: TransactionItem.credit, amount: 56.65)
      expect(transaction).to be_valid
    end
    
    it 'has content in order to be valid' do
      transaction = Transaction.new(attributes.without(:items_attributes))
      expect(transaction).to_not be_valid
    end
  end

  describe '#attachments' do
    let (:transaction) { FactoryGirl.create(:transaction) }

    it 'contains a list of attachments for the transaction' do
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
