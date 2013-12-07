class BalanceSheetReport < Report
  def initialize(entity, filter)
    @entity = entity
    @filter = filter
  end
  
  def content
    # Assets
    assets = _flatten(@entity.accounts.asset)
    asset_total = sum(assets)
    
    # Liabilities
    liabilities = _flatten(@entity.accounts.liability)
    liability_total = sum(liabilities)
    
    # Equity
    equities = _flatten(@entity.accounts.equity)
    equity_total = sum(equities)
    
    retained_earnings = asset_total - (equity_total + liability_total)
    
    # Assemble the final result
    [ { account: 'Assets', balance: format(asset_total), depth: 0 } ] +
    transform(assets) +
    [ { account: 'Liabilities', balance: format(liability_total), depth: 0 } ] +
    transform(liabilities) +
    [ { account: 'Equity', balance: format(equity_total + retained_earnings), depth: 0 } ] +
    transform(equities) +
    [ { account: 'Retained Earnings', balance: format(retained_earnings), depth: 1 } ] +
    [ { account: 'Liabilities + Equity', balance: format((equity_total + retained_earnings) + liability_total), depth: 0 } ]    
  end
  
  private
    def _flatten(accounts)
      flatten accounts, 1, :balance_with_children_as_of, @filter.as_of
    end
end