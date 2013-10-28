require 'ostruct'

module BudgetItemsHelper
  def account_options(budget_item)
    accounts = available_accounts(budget_item.budget.entity)
    grouped_options_for_select accounts, budget_item.account_id
  end
  
  def empty_summary(budget, header)
    result = OpenStruct.new
    result.periods = budget.periods.map { |p| 0}
    result.total = 0
    result.header = header
    result
  end
  
  def period_total(period, items)
    periods = items.map { |i| i.periods.select { |p| p.start_date == period.start_date}.first }
    periods.reduce(0) { |sum, period| sum += period.budget_amount }
  end
  
  def summary(items, budget, header)
    return empty_summary(budget, header) unless items.any?
    result = OpenStruct.new
    result.periods = budget.periods.map { |p| period_total(p, items) }
    result.total = result.periods.reduce(0) { |sum, amount| sum += amount }
    result.header = header
    result
  end
  
  private
    def available_accounts(entity)
      {
        'Assets'      => Account.asset,
        'Liabilities' => Account.liability,
        'Equity'      => Account.equity,
        'Income'      => Account.income,
        'Expense'     => Account.expense
      }
    end
end
