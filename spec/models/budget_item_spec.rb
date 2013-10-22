require 'spec_helper'

describe BudgetItem do
  let(:entity) { FactoryGirl.create(:entity) }
  let(:budget) { FactoryGirl.create(:budget, entity: entity) }
  let(:account) { FactoryGirl.create(:account, entity: entity) }
  let(:attributes) do
    {
      budget_id: budget.id,
      account_id: account.id      
    }
  end
  
  it 'should be creatable from valid attributes' do
    item = BudgetItem.new(attributes)
    item.should be_valid
  end
  
  describe 'budget_id' do
    it 'should be required' do
      item = BudgetItem.new(attributes.without(:budget_id))
      item.should_not be_valid
    end
  end
  
  describe 'budget' do
    it 'should reference the budget to which the item belongs' do
      item = BudgetItem.new(attributes)
      item.budget.should == budget
    end
  end
  
  describe 'account_id' do
    it 'should be required' do
      item = BudgetItem.new(attributes.without(:account_id))
      item.should_not be_valid      
    end
    
    it 'should be unique within a given budget' do
      item = BudgetItem.create!(attributes)
      item2 = BudgetItem.new(attributes)
      item.should be_valid
      item2.should_not be_valid
    end
  end
  
  describe 'account' do
    it 'should reference the account for which amounts are specified' do
      item = BudgetItem.new(attributes)
      item.account.should == account
    end
  end  
end
