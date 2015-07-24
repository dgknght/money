class AccountRecordAdapter
  attr_reader :account, :depth

  def balance
    @account.value_with_children
  end

  def caption
    @account.name
  end

  def identifier
    "account_#{@account.id}"
  end

  def initialize(account, depth)
    @account = account
    @depth = depth
  end
end
