require 'spec_helper'

describe BudgetFilter do
  let(:budget) { FactoryGirl.create(:budget) }
  let(:attributes) do
    {
      start_date: '2013-01-01',
      end_date: '2013-12-31',
      budget_id: budget.id
    }
  end

  it 'should be creatable from valid attributes' do
    filter = BudgetFilter.new(attributes)
    filter.should be_valid
    filter.start_date.should == Date.civil(2013, 1, 1)
    filter.end_date.should == Date.civil(2013, 12, 31)
    filter.budget_id.should == budget.id
  end
  
  describe 'budget_id' do
    it 'should be required' do
      filter = BudgetFilter.new(attributes.without(:budget_id))
      filter.should_not be_valid
    end
  end
end
