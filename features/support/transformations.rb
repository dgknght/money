ACCOUNT = Transform(/^account "([^"]+)"$/) do |name|
  account = Account.find_by_name(name)
  account.should_not be_nil
  account
end

CREDIT_ACCOUNT = Transform(/^crediting "([^"]+)"$/) do |name|
  find_account(name)
end
 
DATE_VALUE = Transform(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/) do |month, day, year|
  Date.new(year.to_i, month.to_i, day.to_i)
end

DEBIT_ACCOUNT = Transform(/^debiting "([^"]+)"$/) do |name|
  find_account(name)
end

DOLLAR_AMOUNT = Transform(/^\$([\d,]+(?:\.\d{2})?)$/) do |value|
  scrubbed_value = value.gsub(/[^.0123456789]/, "")
  BigDecimal.new(scrubbed_value)
end

ENTITY = Transform(/^entity "([^"]+)"$/) do |name|
  find_entity(name)
end

USER = Transform(/^user "([^"]+)"$/) do |email|
  find_user(email)
end
 
