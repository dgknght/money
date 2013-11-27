require 'spec_helper'

describe TransactionItemUpdater do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity, name: 'Groceries') }
  let!(:transaction) { FactoryGirl.create(:transaction, entity: entity, amount: 100, description: 'Kroger', debit_account: groceries, credit_account: checking) }
  let (:transaction_item) { transaction.items.select{ |i| i.account.id == checking.id }.first }
  let (:attributes) do
    {
      transaction_date: '2013-02-27',
      description: 'Carnival',
      amount: 123.45,
      other_account_id: groceries.id
    }
  end
  it 'should be creatable from a transaction item and valid attributes' do
    updater = TransactionItemUpdater.new(transaction_item, attributes)
    updater.should be_valid
  end

  describe 'transaction_item' do
    it 'should be required' do
      updater = TransactionItemUpdater.new(nil, attributes)
      updater.should_not be_valid
      updater.should have(1).error_on(:transaction_item)
    end
  end
  
  describe 'update' do
    it 'should return true on success' do
      updater = TransactionItemUpdater.new(transaction_item, attributes)
      updater.update.should be_true
    end
    
    it 'should update the transaction' do
      expect do
        updater = TransactionItemUpdater.new(transaction_item, attributes)
        updater.update
        transaction.reload
      end.to change(transaction, :description).from('Kroger').to('Carnival')
    end
    
    it 'should update the transaction item' do
    
      puts "amount before is #{transaction_item.amount.to_i}"
      
      expect do
        updater = TransactionItemUpdater.new(transaction_item, attributes)
        updater.update
        transaction_item.reload
        
        puts "amount after is #{transaction_item.amount.to_i}"
        
      end.to change(transaction_item, :amount).from(100).to(123.45)
    end
    
  end
end