require 'spec_helper'

describe TransactionPresenter do
  context 'when given an entity' do
    let (:entity) { FactoryGirl.create(:entity) }
    let (:account) { FactoryGirl.create(:account, entity: entity) }
    let!(:transaction1) { FactoryGirl.create(:transaction, entity: entity) }
    let!(:item1) { FactoryGirl.create(:transaction_item, owning_transaction: transaction1, account: account) }
    let!(:transaction2) { FactoryGirl.create(:transaction, entity: entity) }
    let!(:item2) { FactoryGirl.create(:transaction_item, owning_transaction: transaction2) }
    
    context 'and an account' do
      it 'lists the transactions for the entity that include that account' do
        transactions = TransactionPresenter.new(entity: entity, account: account)
        expect(transactions.to_a).to eq([transaction1])
      end
      
      it 'does not include unsaved transactions' do
        unsaved = entity.transactions.new
        transactions = TransactionPresenter.new(entity: entity, account: account)
        expect(transactions.to_a).to eq([transaction1])
      end
    end
    
    it 'lists the transactions for the entity and all accounts' do
      transactions = TransactionPresenter.new(entity: entity)
      expect(transactions.to_a).to eq([transaction1, transaction2])
    end
  end
  
  it 'is empty' do
    transactions = TransactionPresenter.new()
    expect(transactions.to_a).to be_empty
  end
end
