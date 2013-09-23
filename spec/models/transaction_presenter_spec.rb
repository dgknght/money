require 'spec_helper'

describe TransactionPresenter do
  context 'when given an entity' do
    let (:entity) { FactoryGirl.create(:entity) }
    let (:account) { FactoryGirl.create(:account, entity: entity) }
    let!(:transaction1) { FactoryGirl.create(:transaction, entity: entity) }
    let!(:item1) { FactoryGirl.create(:transaction_item, transaction: transaction1, account: account) }
    let!(:transaction2) { FactoryGirl.create(:transaction, entity: entity) }
    let!(:item2) { FactoryGirl.create(:transaction_item, transaction: transaction2) }
    
    context 'and an account' do
      it 'should list the transactions for the entity that include that account' do
        transactions = TransactionPresenter.new(entity: entity, account: account)
        transactions.to_a.should == [transaction1]
      end
      
      it 'should not include unsaved transactions' do
        unsaved = entity.transactions.new
        transactions = TransactionPresenter.new(entity: entity, account: account)
        transactions.to_a.should == [transaction1]
      end
    end
    
    it 'should list the transactions for the entity and all accounts' do
      transactions = TransactionPresenter.new(entity: entity)
      transactions.to_a.should == [transaction1, transaction2]
    end
  end
  
  it 'should be empty' do
    transactions = TransactionPresenter.new()
    transactions.to_a.should be_empty
  end
end