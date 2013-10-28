require 'ostruct'

class BudgetSummary

  def each(block)
    records.each(block)
  end
  
  def headers
    ['Account'] + @budget.periods.map{ |p| p.start_date.strftime('%b %Y') } + ['Total']
  end
  
  def initialize(budget)
    @budget = budget
    
    income_items = rows(budget.items.income, 1)
    income_total = total('Income', income_items)
    
    expense_items = rows(budget.items.expense, -1)
    expense_total = total('Expense', expense_items)
    
    final_total = total('Total', [income_total, expense_total])
    
    @records = [income_total] + income_items + [expense_total] + expense_items + [final_total]
  end
  
  def records
    @records
  end

  private
    def row(item, polarity)
      result = OpenStruct.new
      result.header = item.account.name
      result.columns = item.periods.map { |p| p.budget_amount * polarity }
      result.total = sum(result.columns)
      result.summary = false
      result
    end
    
    def rows(items, polarity)
      items.sort_by{ |i| i.account.name }.map{ |i| row(i, polarity) }
    end
    
    def sum(values)
      values.reduce(0) { |sum, value| sum += value }
    end
    
    def total(header, rows)
      result = OpenStruct.new
      result.header = header
      if rows.any?
        result.columns = rows.map{ |r| r.columns}.transpose.map{ |columns| sum(columns) }
      else
        result.columns = @budget.periods.map{ |p| 0 }
      end
      result.total = sum(result.columns)
      result.summary = true
      result
    end
end