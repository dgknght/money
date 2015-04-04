class BalanceSheetReport < Report
  def initialize(entity, filter=BalanceSheetFilter.new)
    @entity = entity
    @filter = filter
  end
  
  def content
    # Assets
    assets = _flatten(@entity.accounts.asset.root)
    asset_total = sum(assets)
    
    # Liabilities
    liabilities = _flatten(@entity.accounts.liability.root)
    liability_total = sum(liabilities)
    
    # Equity
    equities = _flatten(@entity.accounts.equity.root)
    equity_subtotal = sum(equities)

    # Income
    income = _flatten(@entity.accounts.income.root)
    income_total = sum(income)

    # Expense
    expense = _flatten(@entity.accounts.expense.root)
    expense_total = sum(expense)
    
    retained_earnings = income_total - expense_total
    unrealized_gains = @entity.unrealized_gains
    equity_total = equity_subtotal + retained_earnings + unrealized_gains
    
    # Assemble the final result
    [ { account: 'Assets', balance: format(asset_total), depth: 0 } ] +
    transform(assets) +
    [ { account: 'Liabilities', balance: format(liability_total), depth: 0 } ] +
    transform(liabilities) +
    [ { account: 'Equity', balance: format(equity_total), depth: 0 } ] +
    transform(equities) +
    [ { account: 'Retained Earnings', balance: format(retained_earnings), depth: 1 } ] +
    [ { account: 'Unrealized Gains', balance: format(unrealized_gains), depth: 1 } ] +
    [ { account: 'Liabilities + Equity', balance: format(equity_total + liability_total), depth: 0 } ]
  end
  
  private
    def _flatten(accounts)
      flatten accounts, 1, ->(account) { !account.commodity? }, :value_with_children_as_of, @filter.as_of
    end
end
