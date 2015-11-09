require 'spec_helper'

describe BudgetItemDistributor do
  let(:budget) { FactoryGirl.create(:budget) }
  let(:account) { FactoryGirl.create(:expense_account, entity: budget.entity) }
  let(:budget_item) { FactoryGirl.create(:budget_item, budget: budget, account: account) }
  
  it 'is creatable from a budget item' do
    distributor = BudgetItemDistributor.new(budget_item)
    expect(distributor).to_not be_nil
  end
  
  describe 'distribute (average)' do
    it 'applys the specified amount to each period in the budget item' do
      distributor = BudgetItemDistributor.new(budget_item)
      distributor.method = BudgetItemDistributor.average
      distributor.options = { amount: 199 }
      distributor.distribute
      budget_item.periods.each do |period|
        expect(period.budget_amount).to eq(199)
      end
    end
  end
  
  describe 'distribute (total)' do
    it 'distributes the amount specified across all periods in the budget item' do
      distributor = BudgetItemDistributor.new(budget_item)
      distributor.method = BudgetItemDistributor.total
      distributor.options = { total: 1200 }
      distributor.distribute
      budget_item.periods.each do |period|
        expect(period.budget_amount).to eq(100)
      end
    end
  end
  
  describe 'distribute (direct)' do
    it 'distributes the amount specified across all periods in the budget item' do
      amounts = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111]
      distributor = BudgetItemDistributor.new(budget_item)
      distributor.method = BudgetItemDistributor.direct
      distributor.options = { amounts: amounts }
      distributor.distribute
      budget_item.periods.each_with_index do |period, index|
        expect(period.budget_amount).to eq(amounts[index])
      end
    end
  end
end
