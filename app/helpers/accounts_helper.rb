module AccountsHelper
  def account_link(account)
    return holdings_account_path(account) if account.commodities?
    account_transaction_items_path(account)
  end

  def active_children(account)
    account.children.select { |c| c.shares > 0 }
  end

  def all_accounts(opts = {})
    except = (opts || {}).fetch(:except, [])
    except = Array(except)
    except = except.map{|a| a.is_a?(Account) ? a.id : a}
    {
      'Assets'      => to_array(Account.asset, except),
      'Liabilities' => to_array(Account.liability, except),
      'Equity'      => to_array(Account.equity, except),
      'Income'      => to_array(Account.income, except),
      'Expense'     => to_array(Account.expense, except)
    }
  end
  
  def sum(assets)
    assets.reduce(0) { |sum, asset| sum + asset.balance_with_children }
  end
  
  private
    def working_account_type(account)
      return Account.asset_type unless account && account.account_type
      account.account_type
    end

    def to_array(accounts, except = nil)
      # Currently, this is enforcing a "one-level deep" rule
      # for the accounts. That's something we may want to change in the future
      list = except ? accounts.reject { |a| except.include?(a.id) } : accounts
      list.map { |a| [a.name, a.id]}
    end
end
