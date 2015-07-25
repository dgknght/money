# Organizes accounts for use in lists
class AccountListPresenter
  def initialize(entity)
    @entity = entity
  end

  def grouped_accounts
    Account::ACCOUNT_TYPES.reduce({}) do |result, account_type|
      result[account_type] = accounts_by_type(account_type)
      result
    end
  end

  private

  def accounts_by_type(account_type)
    root_accounts(account_type).reduce([]) do |list, account|
      list + to_list(account)
    end
  end

  def all_accounts
    @all_accounts ||= @entity.accounts.to_a
  end

  def all_children(parent_entry)
    all_accounts.
      select{|a| a.parent_id == parent_entry[1]}.
      map{|a| to_entry(a, parent_entry.first)}.
      reduce([]) {|list, e| list + [e] + all_children(e)}
  end

  def root_accounts(account_type)
    all_accounts.select{|a| a.root? && a.account_type == account_type}
  end

  def to_description(account, prefix)
    prefix.present? ? "#{prefix}/#{account.name}" : account.name
  end

  def to_entry(account, prefix = nil)
    [to_description(account, prefix), account.id]
  end

  def to_list(account)
    entry = to_entry(account)
    [entry] + all_children(entry)
  end
end
