module AccountsHelper
  def available_parent_accounts(account)
#    account_type = working_account_type(account)
#    accounts = Account.where(account_type: account_type)
    
#    accounts = accounts.where('id != ?', account.id) unless account.new_record?
#    accounts

    account.new_record? ? Account.all : Account.where('id != ?', account.id)
  end
  
  def sum(assets)
    assets.reduce(0) { |sum, asset| sum + asset.balance_with_children }
  end
  
  private
    def working_account_type(account)
      return Account.asset_type unless account && account.account_type
      account.account_type
    end
end
