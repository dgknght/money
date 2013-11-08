require 'spec_helper'

describe ReconciliationItem do
  let (:transaction_item) { FactoryGirl.create(:transaction_item) }
  let (:reconciliation) { FactoryGirl.create(:reconciliation) }
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
  
  describe 'reconciliation_id' do
    it 'should be required' do
      item = ReconciliationItem.new(attributes.without(:reconciliation))
      item.should have(1).error_on(:reconciliation_id)
    end
  end
end
