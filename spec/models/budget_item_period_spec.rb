require 'spec_helper'

describe BudgetItemPeriod do
  let (:budget_item) { FactoryGirl.create(:budget_item) }
  let (:attributes) do
    {
      budget_item_id: budget_item.id,
      start_date: '2014-01-01',
      budget_amount: 100
    }
  end
  
  it 'should be creatable from valid attributes' do
    period = BudgetItemPeriod.new(attributes)
    period.should be_valid
  end
  
  describe 'budget_item_id' do
    it 'should be required' do
      period = BudgetItemPeriod.new(attributes.without(:budget_item_id))
      period.should_not be_valid
    end
  end  
 
  describe 'start_date' do
    it 'should be required' do
      period = BudgetItemPeriod.new(attributes.without(:start_date))
      period.should_not be_valid
    end
  end  
 
  describe 'budget_amount' do
    it 'should be required' do
      period = BudgetItemPeriod.new(attributes.without(:budget_amount))
      period.should_not be_valid
    end
  end  
end
