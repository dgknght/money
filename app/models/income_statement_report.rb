class IncomeStatementReport < Report
  
  def content
    # Income
    income = _flatten(@entity.accounts.income)
    income_total = sum(income)
    
    # Expense
    expense = _flatten(@entity.accounts.expense)
    expense_total = sum(expense)
    
    # Assemble the final result
    [{ account: 'Income', balance: format(income_total), depth: 0}] +
      transform(income) +
      [{ account: 'Expense', balance: format(expense_total), depth: 0}] +
      transform(expense) +
      [{ account: 'Net', balance: format(income_total - expense_total), depth: 0}]
  end
  
  def initialize(entity, filter=IncomeStatementFilter.new)
    @entity = entity
    @filter = filter.is_a?(IncomeStatementFilter) ? filter : IncomeStatementFilter.new(filter)
  end
  
  private
    def _flatten(accounts)
      flatten accounts, 1, ->(a) { true }, :balance_with_children_between, @filter.from, @filter.to
    end
    
    def f(accounts, depth = 1)
      accounts.map do |account|
        [
          { account: account, depth: depth, balance: account.balance_with_children_between(@filter.from, @filter.to) },
          f(account.children, depth + 1)
        ]
      end.flatten
    end
end
