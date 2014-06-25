class AccountRecordAdapter
  def balance
    @account.balance_with_children
  end

  def caption
    @account.name
  end

  def depth
    @account.depth + 1
  end

  def initialize(account)
    @account = account
  end
end
