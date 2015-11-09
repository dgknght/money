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

  it 'is creatable from valid attributes' do
    filter = BudgetFilter.new(attributes)
    expect(filter).to be_valid
    expect(filter.start_date).to eq(Date.civil(2013, 1, 1))
    expect(filter.end_date).to eq(Date.civil(2013, 12, 31))
    expect(filter.budget_id).to eq(budget.id)
  end
  
  describe 'budget_id' do
    it 'is required' do
      filter = BudgetFilter.new(attributes.without(:budget_id))
      expect(filter).to_not be_valid
    end
  end
end
