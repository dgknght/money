require 'spec_helper'

describe Reconciliation do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, name: 'Checking', entity: entity) }
  let (:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'Salary') }
  let (:transaction) { FactoryGirl.create(:transaction, amount: 1_000, debit_account: checking, credit_account: salary) }
  let (:attributes) do
    {
      account_id: checking.id,
      reconciliation_date: '2013-02-28',
      closing_balance: 1_000,
      items_attributes: [
        transaction_item_id: transaction.items.select{ |i| i.account.id == checking.id }.first.id
      ]
    }
  end
  
  it 'should be creatable from valid attributes' do
    reconciliation = Reconciliation.new(attributes)
    reconciliation.should be_valid
  end
  
  describe 'account_id' do
    it 'should be required' do
      reconciliation = Reconciliation.new(attributes.without(:account_id))
      reconciliation.should have(1).error_on(:account_id)
    end
  end
  
  describe 'reconciliation_date' do
    it 'should default to one month after the previous close, if available' do
      r1 = Reconciliation.create!(attributes)
      
      r2 = Reconciliation.new(attributes.without(:reconciliation_date).merge(closing_balance: 0, items_attributes: []))            
      r2.should be_valid
      r2.reconciliation_date.should == Date.civil(2013, 3, 28)
    end
    
    it 'should default to today if no previous close is available' do
      reconciliation = Reconciliation.new(attributes.without(:reconciliation_date))
      reconciliation.should be_valid
      reconciliation.reconciliation_date.should == Date.today
    end
  end
  
  describe 'closing_balance' do
    it 'should be required' do
      reconciliation = Reconciliation.new(attributes.without(:closing_balance))
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
  
  describe 'items' do
    it 'should be empty by default' do
      reconciliation = Reconciliation.new(attributes.without(:items_attributes))
      reconciliation.items.should be_empty
    end
  end
  
  describe 'reconciled_balance' do
    let!(:t1) { FactoryGirl.create(:transaction, entity: entity, description: 'Paycheck', transaction_date: '2013-01-01', amount: 1_000, credit_account: salary, debit_account: checking) }
    let (:checking_item) do
      t1.items.select{ |i| i.account_id == checking.id}.first
    end
    it 'should be the previous_balance plus any selected transaction items' do
      reconciliation = Reconciliation.new(attributes.without(:items_attributes))
      reconciliation.reconciled_balance.should == 0
      
      reconciliation << checking_item
      reconciliation.reconciled_balance.should == 1_000
    end
  end
  
  describe 'balance_difference' do
    let!(:t1) { FactoryGirl.create(:transaction, entity: entity, description: 'Paycheck', transaction_date: '2013-01-01', amount: 1_000, credit_account: salary, debit_account: checking) }
    let (:checking_item) do
      t1.items.select{ |i| i.account_id == checking.id}.first
    end
    it 'must be zero' do
      reconciliation = Reconciliation.new(attributes.without(:items_attributes))
      reconciliation.should have(1).error_on(:balance_difference)
      
      item = reconciliation << checking_item
      reconciliation.should be_valid
    end
  end
end
