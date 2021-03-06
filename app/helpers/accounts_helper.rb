module AccountsHelper
  def account_link(account)
    return holdings_account_path(account) if account.commodities?
    account_transaction_items_path(account)
  end

  def active_children(account)
    account.children.select { |c| c.shares > 0 }
  end

  def grouped_accounts(entity, opts = {})
    except = (opts || {}).fetch(:except, [])
    except = Array(except)
    except = except.map{|a| a.is_a?(Account) ? a.id : a}
    {
      'Assets'      => to_array(entity.accounts.asset, except),
      'Liabilities' => to_array(entity.accounts.liability, except),
      'Equity'      => to_array(entity.accounts.equity, except),
      'Income'      => to_array(entity.accounts.income, except),
      'Expense'     => to_array(entity.accounts.expense, except)
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
      list.map { |a| [a.path, a.id]}.sort_by{|a| a.first}
    end
end
