class BalanceSheetReport
  include ActionView::Helpers::NumberHelper
  
  def initialize(entity, filter)
    @entity = entity
    @filter = filter
  end
  
  def content
    # Assets
    assets = flatten(@entity.accounts.asset)
    asset_total = sum(assets)
    
    # Liabilities
    liabilities = flatten(@entity.accounts.liability)
    liability_total = sum(liabilities)
    
    # Equity
    equities = flatten(@entity.accounts.equity)
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
    def transform(records)
      records.map do |record|
        {
          account: record[:account].name,
          balance: format(record[:balance]),
          depth: record[:depth]
        }
      end
    end
    
    def flatten(accounts, depth = 1)
      accounts.map do |account|
        [
          { account: account, depth: depth, balance: account.balance_with_children_as_of(@filter.as_of) },
          flatten(account.children, depth + 1)
        ]
      end.flatten
    end
    
    def format(value)
      number_to_currency(value, unit: '')
    end
    
    def sum(rows)
      rows.select{ |row| row[:depth] == 1 }.reduce(0) { |sum, row| sum += row[:balance]}
    end
end