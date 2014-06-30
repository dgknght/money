module AccountsHelper
  def account_link(account)
    return account_holdings_path(account) if account.commodities?
    account_transaction_items_path(account)
  end

  def available_parent_accounts(account)
    {
      'Assets'      => to_array(Account.asset, account.id),
      'Liabilities' => to_array(Account.liability, account.id),
      'Equity'      => to_array(Account.equity, account.id),
      'Income'      => to_array(Account.income, account.id),
      'Expense'     => to_array(Account.expense, account.id)
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
      list = except ? accounts.reject { |a| a.id == except } : accounts
      list.map { |a| [a.name, a.id]}
    end
end
