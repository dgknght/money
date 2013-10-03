DOLLAR_AMOUNT = Transform(/^\$([\d,]+(?:\.\d{2})?)$/) do |value|
  BigDecimal.new(value)
end

ENTITY = Transform(/^entity "([^"]+)"$/) do |name|
  find_entity(name)
end

USER = Transform(/^user "([^"]+)"$/) do |email|
  find_user(email)
end

Given(/^(#{ENTITY}) has an? (liability|asset|equity|income|expense) account named "([^"]+)"(?: with a balance of (#{DOLLAR_AMOUNT}))?$/) do |entity, type, name, balance|
  entity.accounts.find_by_name(name) || entity.accounts.create!(name: name, account_type: type, balance: balance || 0)
end

Given(/^(#{USER}) has an? (liability|asset|equity|income|expense) account named "([^"]+)"(?: with a balance of (#{DOLLAR_AMOUNT}))?$/) do |user, type, name, balance|
  entity = user.entities.first
  entity.should_not be_nil
  typed_balance = balance.nil? ? 0 : BigDecimal.new(balance)
  entity.accounts.find_by_name(name) || entity.accounts.create!(name: name, account_type: type, balance: typed_balance)
end