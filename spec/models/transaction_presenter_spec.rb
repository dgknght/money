require 'spec_helper'

describe TransactionPresenter do
  context 'when given a user' do
    let (:user) { FactoryGirl.create(:user) }
    let (:account) { FactoryGirl.create(:account, user: user) }
    let!(:transaction1) { FactoryGirl.create(:transaction, user: user) }
    let!(:item1) { FactoryGirl.create(:transaction_item, transaction: transaction1, account: account) }
    let!(:transaction2) { FactoryGirl.create(:transaction, user: user) }
    let!(:item2) { FactoryGirl.create(:transaction_item, transaction: transaction2) }
    
    context 'and an account' do
      it 'should list the transactions for the user that include that account' do
        transactions = TransactionPresenter.new(user: user, account: account)
        transactions.to_a.should == [transaction1]
      end
      
      it 'should not include unsaved transactions' do
        unsaved = user.transactions.new
        transactions = TransactionPresenter.new(user: user, account: account)
        transactions.to_a.should == [transaction1]
      end
    end
    
    it 'should list the transactions for the user and all accounts' do
      transactions = TransactionPresenter.new(user: user)
      transactions.to_a.should == [transaction1, transaction2]
    end
  end
  
  it 'should be empty' do
    transactions = TransactionPresenter.new()
    transactions.to_a.should be_empty
  end
end