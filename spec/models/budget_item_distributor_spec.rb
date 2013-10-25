require 'spec_helper'

describe BudgetItemDistributor do
  let(:budget) { FactoryGirl.create(:budget) }
  let(:account) { FactoryGirl.create(:expense_account, entity: budget.entity) }
  let(:budget_item) { FactoryGirl.create(:budget_item, budget: budget, account: account) }
  
  describe 'distribute (average)' do
    it 'should apply the specified amount to each period in the budget item' do
      BudgetItemDistributor.distribute(budget_item, :average, 199)
      budget_item.periods.each do |period|
        period.budget_amount.should == 199
      end
    end
  end
  
  describe 'distribute (total)' do
    it 'should distribute the amount specified across all periods in the budget item' do
      BudgetItemDistributor.distribute(budget_item, :total, 1200)
      budget_item.periods.each do |period|
        period.budget_amount.should == 100
      end
    end
  end
  
  describe 'distribute (direct)' do
    it 'should distribute the amount specified across all periods in the budget item' do
      amounts = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111]
      BudgetItemDistributor.distribute(budget_item, :direct, amounts)
      budget_item.periods.each_with_index do |period, index|
        period.budget_amount.should == amounts[index]
      end
    end
  end
end