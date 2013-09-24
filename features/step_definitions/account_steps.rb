Given(/^entity "([^"]+)" has an? (liability|asset|equity|income|expense) account named "([^"]+)"(?: with a balance of ([\d\.]+))?$/) do |entity_name, type, name, balance|
  entity = find_entity(entity_name)
  typed_balance = balance.nil? ? 0 : BigDecimal.new(balance)
  entity.accounts.find_by_name(name) || entity.accounts.create!(name: name, account_type: type, balance: typed_balance)
end

Given(/^user "([^"]+)" has an? (liability|asset|equity|income|expense) account named "([^"]+)"(?: with a balance of ([\d\.]+))?$/) do |email, type, name, balance|
  user = find_user(email)
  entity = user.entities.first
  entity.should_not be_nil
  typed_balance = balance.nil? ? 0 : BigDecimal.new(balance)
  entity.accounts.find_by_name(name) || entity.accounts.create!(name: name, account_type: type, balance: typed_balance)
end