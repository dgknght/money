class IncomeStatementReport
  include ActionView::Helpers::NumberHelper
  
  def content
    # Income
    income = flatten(@entity.accounts.income)
    income_total = sum(income)
    
    # Expense
    expense = flatten(@entity.accounts.expense)
    expense_total = sum(expense)
    
    # Assemble the final result
    [{ account: 'Income', balance: format(income_total), depth: 0}] +
      transform(income) +
      [{ account: 'Expense', balance: format(expense_total), depth: 0}] +
      transform(expense) +
      [{ account: 'Net', balance: format(income_total - expense_total), depth: 0}]
  end
  
  def initialize(entity, filter)
    @entity = entity
    @filter = filter.is_a?(IncomeStatementFilter) ? filter : IncomeStatementFilter.new(filter)
  end
  
  private
    def flatten(accounts, depth = 1)
      accounts.map do |account|
        [
          { account: account, depth: depth, balance: account.balance_with_children_between(@filter.from, @filter.to) },
          flatten(account.children, depth + 1)
        ]
      end.flatten
    end
    
    # This is duplicated between this class and BalanceSheetReport.....need to move it to a shared location
    def format(value)
      number_to_currency(value, unit: '')
    end    
    
    # This is duplicated between this class and BalanceSheetReport.....need to move it to a shared location
    def sum(rows)
      rows.select{ |row| row[:depth] == 1 }.reduce(0) { |sum, row| sum += row[:balance]}
    end
    
    # This is duplicated between this class and BalanceSheetReport.....need to move it to a shared location
    def transform(records)
      records.map do |record|
        {
          account: record[:account].name,
          balance: format(record[:balance]),
          depth: record[:depth]
        }
      end
    end
end