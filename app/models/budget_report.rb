require 'ostruct'

# Creates report content for budget reports
class BudgetReport
  include ActionView::Helpers::NumberHelper
  
  def content
    period_count = filter_periods(@budget.items[0].periods).length
    
    income_items = @budget.items.income.map { |i| to_report_row(i, 1) }
    income_total = total(income_items, 'Income', period_count)
    expense_items = @budget.items.expense.map { |i| to_report_row(i, -1) }
    expense_total = total(expense_items, 'Expense', period_count)
    net_total = total([income_total, expense_total], 'Net', period_count)
    
    all_items = [income_total] + income_items + [expense_total] + expense_items + [net_total]
    format_items(all_items)
  end

  def initialize(budget, filter)
    raise 'A budget must be specified' unless budget
    @budget = budget
    
    raise 'A filter must be specified' unless filter
    @filter = filter
  end

  private
    def filter_periods(periods)
      periods.select { |p| @filter.start_date <= p.end_date && p.start_date <= @filter.end_date }
    end

    def format_currency(value)
      number_to_currency(value, unit: '')
    end    
    
    def format_item(item)
      OpenStruct.new(
        account: item.account,
        budget_amount: format_currency(item.budget_amount),
        actual_amount: format_currency(item.actual_amount),
        difference: format_currency(item.difference),
        percent_difference: format_percent(item.percent_difference),
        actual_per_month: format_currency(item.actual_per_month)
      )
    end
    
    def format_items(items)
      items.map { |i| format_item(i) }
    end
    
    def format_percent(value)
      number_to_percentage(value, precision: 1)
    end
    
    def new_row(header, budget_amount, actual_amount, period_count)
      period_count = 1 if period_count == 0
      difference = actual_amount - budget_amount
      percent_difference = budget_amount != 0 ? ((difference / budget_amount.abs) * 100) : nil
      actual_per_month = actual_amount / period_count
      OpenStruct.new(
        account: header,
        budget_amount: budget_amount,
        actual_amount: actual_amount,
        difference: difference,
        percent_difference: percent_difference,
        actual_per_month: actual_per_month
      )
    end
    
    def sum(periods, method)
      periods.reduce(0) { |sum, period| sum += period.send(method) }
    end

    def to_report_row(item, polarity)
      periods = filter_periods(item.periods)
      budget_amount = sum(periods, :budget_amount) * polarity
      actual_amount = sum(periods, :actual_amount) * polarity
      new_row(item.account.name, budget_amount, actual_amount, periods.length)
    end
    
    def total(items, header, period_count)
      budget_amount = items.reduce(0) { |s, item| s += item.budget_amount }
      actual_amount = items.reduce(0) { |s, item| s += item.actual_amount }
      new_row(header, budget_amount, actual_amount, period_count)
    end
end
