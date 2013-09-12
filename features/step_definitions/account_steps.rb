Given(/^user "([^"]+)" has an? (liability|asset|equity) account named "([^"]+)"$/) do |email, type, name|
  user = find_user(email)
  user.accounts.find_by_name(name) || user.accounts.create!(:name => name, :account_type => type.to_sym)
end