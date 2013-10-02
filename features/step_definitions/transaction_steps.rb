
DATE_VALUE = Transform(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/) do |month, day, year|
  Date.new(year.to_i, month.to_i, day.to_i)
end

DOLLAR_AMOUNT = Transform(/^\$(\d+(?:\.\d{2})?)$/) do |value|
  BigDecimal.new(value)
end

ENTITY = Transform(/^entity "([^"]+)"$/) do |name|
  find_entity(name)
end

CREDIT_ACCOUNT = Transform(/^crediting "([^"]+)"$/) do |name|
  find_account(name)
end
 
DEBIT_ACCOUNT = Transform(/^debiting "([^"]+)"$/) do |name|
  find_account(name)
end
 
Given(/^(#{ENTITY}) has a transaction "([^"]+)" on (#{DATE_VALUE}) (#{CREDIT_ACCOUNT}) (#{DOLLAR_AMOUNT}) and (#{DEBIT_ACCOUNT}) (#{DOLLAR_AMOUNT})$/) do |entity, description, date, credit_account, credit_amount, debit_account, debit_amount|
  items = [
    { account: credit_account, action: TransactionItem.credit, amount: credit_amount },
    { account: debit_account, action: TransactionItem.debit, amount: debit_amount }
  ]
  transaction = entity.transactions.create!(description: description, transaction_date: date, items_attributes: items)
end

When(/^I enter a transaction for (#{ENTITY}) called "([^"]+)" on (#{DATE_VALUE}) (#{CREDIT_ACCOUNT}) (#{DOLLAR_AMOUNT}) and (#{DEBIT_ACCOUNT}) (#{DOLLAR_AMOUNT})$/) do |entity, description, transaction_date, credit_account, credit_amount, debit_account, debit_amount|
  items = [
    { account: credit_account, action: TransactionItem.credit, amount: credit_amount },
    { account: debit_account, action: TransactionItem.debit, amount: debit_amount }
  ]
  transaction = entity.transactions.create!(description: description, transaction_date: transaction_date, items_attributes: items)
  visit entity_transactions_path(entity)
end
