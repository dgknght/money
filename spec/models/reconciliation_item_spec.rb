require 'spec_helper'

describe ReconciliationItem do
  let (:account) { FactoryGirl.create(:account) }
  let (:transaction_item) { FactoryGirl.create(:transaction_item, account: account) }
  let (:reconciliation) { FactoryGirl.create(:reconciliation, account: account) }
  let (:attributes) do
    {
      reconciliation: reconciliation,
      transaction_item: transaction_item
    }
  end
  
  it 'should be creatable from valid attributes' do
    item = ReconciliationItem.new(attributes)
    item.should be_valid
  end
  
  describe 'transaction_item_id' do
    it 'should be required' do
      item = ReconciliationItem.new(attributes.without(:transaction_item))
      item.should have(1).error_on(:transaction_item_id)
    end
  end
  
  describe 'transaction' do
    let (:from_other_account) { FactoryGirl.create(:transaction_item) }
    
    it 'must be from the account being reconciled' do
      item = ReconciliationItem.new(attributes.merge(transaction_item: from_other_account))
      item.should have(1).error_on(:transaction_item)
    end
  end
  
  describe 'reconciliation' do
    it 'should be required' do
      item = ReconciliationItem.new(attributes.without(:reconciliation))
      item.should have(1).error_on(:reconciliation)
    end
  end
end
