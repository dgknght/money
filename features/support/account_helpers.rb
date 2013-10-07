module AccountHelpers
  def ensure_account(name, type, entity)
    entity.accounts.find_by_name(name) || entity.accounts.create!(name: name, account_type: type)
  end
  
  def ensure_accounts(names, type, entity)
    result = names.map { |name| ensure_account(name, type, entity) }
    result.reduce(nil) do |parent, account|
      if parent
        account.parent_id = parent.id
        account.save!
      end
    end
    result
  end
    
  def find_account(name)
    result = Account.find_by_name(name)
    result.should_not be_nil
    result
  end
end
World(AccountHelpers)