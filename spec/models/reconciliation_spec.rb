require 'spec_helper'

describe Reconciliation do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, name: 'Checking', entity: entity) }
  let (:attributes) do
    {
      account_id: checking.id,
      reconciliation_date: '2013-02-28',
      closing_balance: 1_000
    }
  end
  
  it 'should be creatable from valid attributes' do
    reconciliation = Reconciliation.new(attributes)
    reconciliation.should be_valid
  end
  
  describe 'account_id' do
    it 'should be required' do
      reconciliation = Reconciliation.new(attributes.without(:account_id))
      reconciliation.should_not be_valid
      reconciliation.should have(1).error_on(:account_id)
    end
  end
  
  describe 'reconciliation_date' do
    it 'should be required' do
      reconciliation = Reconciliation.new(attributes.without(:reconciliation_date))
      reconciliation.should_not be_valid
      reconciliation.should have(1).error_on(:reconciliation_date)
    end
  end
  
  describe 'closing_balance' do
    it 'should be required' do
      reconciliation = Reconciliation.new(attributes.without(:closing_balance))
      reconciliation.should_not be_valid
      reconciliation.should have(1).error_on(:closing_balance)
    end
  end
  
  describe 'prevous_balance' do
    context 'when there are no previous reconciliations for the account' do
      it 'should be zero' do
        reconciliation = Reconciliation.new(attributes)
        reconciliation.previous_balance.should == 0
      end
    end
    
    context 'when there is at least one previous reconciliation for the account' do
      let!(:previous) { FactoryGirl.create(:reconciliation, account: checking, reconciliation_date: '2013-01-31', closing_balance: 1_000) }
      it 'should be the closing balance from the previous reconciliation for the same account' do
        reconciliation = Reconciliation.new(attributes)
        reconciliation.previous_balance.should == 1_000
      end
    end
  end
  
  describe 'reconciled_balance' do
    let (:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'Salary') }
    let!(:t1) { FactoryGirl.create(:transaction, entity: entity, description: 'Paycheck', transaction_date: '2013-01-01', amount: 1_000, credit_account: salary, debit_account: checking) }
    
    it 'should be the previous_balance plus any selected transaction items' do
      reconciliation = Reconciliation.new(attributes)
      reconciliation.reconciled_balance.should == 0
      
      reconciliation.items_attributes = [ { transaction_item_id: t1.id } ]
      reconciliation.reconciled_balance.should == 1_000
    end
    
    it 'must be the same as closing_balance in order for the reconciliation to save'
  end
end
