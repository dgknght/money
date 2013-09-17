Given(/^user "([^"]+)" has an? (liability|asset|equity|income|expense) account named "([^"]+)"(?: with a balance of ([\d\.]+))?$/) do |email, type, name, balance|
  user = find_user(email)
  typed_balance = balance.nil? ? 0 : BigDecimal.new(balance)
  user.accounts.find_by_name(name) || user.accounts.create!(name: name, account_type: type.to_sym, balance: typed_balance)
end