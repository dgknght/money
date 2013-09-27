
DATE_VALUE = Transform(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/) do |month, day, year|
  Date.new(year.to_i, month.to_i, day.to_i)
end

DOLLAR_AMOUNT = Transform(/^\$(\d+(?:\.\d{2})?)$/) do |value|
  BigDecimal.new(value)
end

ENTITY = Transform(/^entity "([^"]+)"$/) do |name|
  find_entity(name)
end
 
Given(/^(#{ENTITY}) has a transaction "([^"]+)" on (#{DATE_VALUE}) crediting "([^"]+)" (#{DOLLAR_AMOUNT}) and debiting "([^"]+)" (#{DOLLAR_AMOUNT})$/) do |entity, description, date, credit_account_name, credit_amount, debit_account_name, debit_amount|
  credit_account = find_account(credit_account_name)
  debit_account = find_account(debit_account_name)
  items = [
    { account: credit_account, action: TransactionItem.credit, amount: credit_amount },
    { account: debit_account, action: TransactionItem.debit, amount: debit_amount }
  ]
  transaction = entity.transactions.create!(description: description, transaction_date: date, items_attributes: items)
end
