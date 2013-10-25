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
end