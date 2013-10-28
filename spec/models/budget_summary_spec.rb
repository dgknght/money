require 'spec_helper'

describe BudgetSummary do
  let (:budget) { FactoryGirl.create(:budget) }
 
  let (:salary) { FactoryGirl.create(:income_account, entity: budget.entity, name: 'Salary') }
  let (:bonus)  { FactoryGirl.create(:income_account, entity: budget.entity, name: 'Bonus') }
  
  let (:groceries) { FactoryGirl.create(:expense_account, entity: budget.entity, name: 'Groceries') }
  let (:dining)    { FactoryGirl.create(:expense_account, entity: budget.entity, name: 'Dining') }
  
  let!(:salary_item) { FactoryGirl.create(:budget_item, budget: budget, account: salary, budget_amount: 4000) }
  let!(:bonus_item)  { FactoryGirl.create(:budget_item, budget: budget, account: bonus,  budget_amount: 100) }
  
  let!(:dining_item)    { FactoryGirl.create(:budget_item, budget: budget, account: dining,    budget_amount: 500) }
  let!(:groceries_item) { FactoryGirl.create(:budget_item, budget: budget, account: groceries, budget_amount: 300) }
  
  describe 'headers' do
    it 'should contain the the correct column headers' do
      summary = BudgetSummary.new(budget)
      summary.headers.should == [
        'Account',
        'Jan 2014',
        'Feb 2014',
        'Mar 2014',
        'Apr 2014',
        'May 2014',
        'Jun 2014',
        'Jul 2014',
        'Aug 2014',
        'Sep 2014',
        'Oct 2014',
        'Nov 2014',
        'Dec 2014',
        'Total'
      ]
    end
  end
  
  describe 'records' do
    it 'should contain the correct header data' do
      summary = BudgetSummary.new(budget)
      summary.should have(7).records
      summary.records.map{ |r| r.header }.should == ['Income', 'Bonus', 'Salary', 'Expense', 'Dining', 'Groceries', 'Total']
    end
    
    it 'should contain the correct total data' do
      summary = BudgetSummary.new(budget)
      summary.should have(7).records
      summary.records.map{ |r| r.total }.should == [49_200, 1_200, 48_000, -9_600, -6_000, -3_600, 39_600]
    end  
  end
end