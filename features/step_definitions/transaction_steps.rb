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

Given(/^(#{ENTITY}) has the following transactions$/) do |entity, table|
  table.hashes.each do |row|
    credit_account = find_account(row['Credit account'])
    debit_account = find_account(row['Debit account'])
    amount = BigDecimal.new(row['Amount'].gsub(/[^.0123456789]/, ""))
    FactoryGirl.create(:transaction, entity: entity, transaction_date: row['Transaction date'], description: row['Description'], amount: amount, credit_account: credit_account, debit_account: debit_account)
  end
end
