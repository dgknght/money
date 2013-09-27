module AccountHelpers
  def find_account(name)
    result = Account.find_by_name(name)
    result.should_not be_nil
    result
  end
end
World(AccountHelpers)