Given(/^user "([^"]+)" has an? (liability|asset|equity) account named "([^"]+)"$/) do |email, type, name|
  user = find_user(email)
  user.accounts.find_by_name(name) || user.accounts.create!(:name => name, :type => type)
end