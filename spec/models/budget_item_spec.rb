require 'spec_helper'

describe BudgetItem do
  let(:entity) { FactoryGirl.create(:entity) }
  let(:budget) { FactoryGirl.create(:budget, entity: entity) }
  let(:salary) { FactoryGirl.create(:income_account, entity: entity) }
  let(:groceries) { FactoryGirl.create(:expense_account, entity: entity) }
  let(:attributes) do
    {
      budget_id: budget.id,
      account_id: groceries.id      
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
      item.account.should == groceries
    end
  end
  
  describe 'periods' do
    it 'should contain a list of the periods within the budget' do
      item = budget.items.create(attributes)
      item.periods.should_not be_nil
      item.should have(12).periods
      item.periods.map { |p| p.start_date }.should == (1..12).map { |month| Date.civil(2014, month, 1) }
    end
  end
  
  describe 'scope' do
    let!(:salary_item) { FactoryGirl.create(:budget_item, budget: budget, account: salary) }
    let!(:groceries_item) { FactoryGirl.create(:budget_item, budget: budget, account: groceries) }
    
    describe 'income' do
      it 'should return budget items for income accounts' do
        budget.items.income.should == [salary_item]
      end
    end
    
    describe 'expense' do
      it 'should return budget items for expense accounts' do
        budget.items.expense.should == [groceries_item]
      end
    end
  end
end
