class BalanceSheetReport
  include ActionView::Helpers::NumberHelper
  
  def initialize(entity, filter)
    @entity = entity
    @filter = filter
  end
  
  def content
    assets = transform(@entity.accounts.asset);
    asset_total = sum(@entity.accounts.asset);
    
    liabilities = transform(@entity.accounts.liability)
    liability_total = sum(@entity.accounts.liability)
    
    equities = transform(@entity.accounts.equity)
    equity_total = sum(@entity.accounts.equity)
    
    retained_earnings = asset_total - (equity_total + liability_total)
    equities << { account: 'Retained Earnings', balance: format(retained_earnings), depth: 1 }
    
    [ { account: 'Assets', balance: format(asset_total), depth: 0 } ] +
    assets +
    [ { account: 'Liabilities', balance: format(liability_total), depth: 0 } ] +
    liabilities +
    [ { account: 'Equity', balance: format(equity_total + retained_earnings), depth: 0 } ] +
    equities
  end
  
  private
    def transform(accounts)
      flatten(accounts, 1).map do |record|
        {
          account: record[:account].name,
          balance: format(record[:account].balance_with_children),
          depth: record[:depth]
        }
      end
    end
    
    def flatten(accounts, depth = 0)
      accounts.map do |account|
        [
          { account: account, depth: depth },
          flatten(account.children, depth + 1)
        ]
      end.flatten
    end
    
    def format(value)
      number_to_currency(value, unit: '')
    end
    
    def sum(accounts)
      accounts.reduce(0) { |sum, account| sum += account.balance_with_children }
    end
end