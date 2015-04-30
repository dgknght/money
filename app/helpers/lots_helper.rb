module LotsHelper
  def account_options_for_transfer
    accounts = @transfer.lot.account.entity.accounts.commodities.reject{|a| a.id == @account_id}
    options_from_collection_for_select(accounts, :id, :path)
  end
end
