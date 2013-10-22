require 'spec_helper'

describe Budget do
  let (:entity) { FactoryGirl.create(:entity) }
  
  let (:attributes) do
    {
      entity_id: entity.id,
      name: '2014 budget',
      start_date: '2014-01-01',
      end_date: '2014-12-31'
    }
  end
  
  it 'should be creatable from valid attributes' do
    budget = Budget.new(attributes)
    budget.should be_valid
  end
  
  describe 'name' do
    it 'should be required' do
      budget = Budget.new(attributes.without(:name))
      budget.should_not be_valid
    end
    
    it 'should be unique' do
      budget1 = Budget.create!(attributes)
      budget2 = Budget.new(FactoryGirl.attributes_for(:budget).merge(name: attributes[:name]))
      budget2.should_not be_valid
    end
  end
  
  describe 'start_date' do
    it 'should be required' do
      budget = Budget.new(attributes.without(:start_date))
      budget.should_not be_valid
    end
  end
  
  describe 'end_date' do
    it 'should be required' do
      budget = Budget.new(attributes.without(:end_date))
      budget.should_not be_valid
    end
    
    it 'should be after the start date' do
      budget = Budget.new(attributes.merge(end_date: '2013-12-31'))
      budget.should_not be_valid
    end
  end
  
  describe 'items' do
    let(:budget) { FactoryGirl.create(:budget) }
    let(:item1) { FactoryGirl.create(:budget_item, budget: budget) }
    let(:item2) { FactoryGirl.create(:budget_item, budget: budget) }
    it 'should contain the items that belong to the budget' do
      budget.items.should == [item1, item2]
    end
  end
end
