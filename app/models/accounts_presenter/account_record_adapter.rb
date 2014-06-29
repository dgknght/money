class AccountRecordAdapter
  def account
    @account
  end

  def balance
    @account.value
  end

  def caption
    @account.name
  end

  def depth
    @account.depth + 1
  end

  def identifier
    "account_#{@account.id}"
  end

  def initialize(account)
    @account = account
  end
end
