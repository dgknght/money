ACCOUNT = Transform(/^account "([^"]+)"$/) do |name|
  account = Account.find_by_name(name)
  account.should_not be_nil
  account
end

Given(/^I have reconciled (#{ACCOUNT}) as of (#{DATE_VALUE}) at a balance of (#{DOLLAR_AMOUNT}) including the following items$/) do |account, reconciliation_date, closing_balance, items|
  items_attributes = items.hashes.map do |item|
    item.merge(
      amount: BigDecimal.new(item['Amount'].gsub(/[^.0123456789]/, ""))
    )
  end.map do |item|
    TransactionItem.where(
      'account_id=? and amount=?',
      account.id,
      item[:amount]
      ).first
  end.map do |item|
    { transaction_item_id: item.id }
  end
  
  reconciliation = account.reconciliations.create!(reconciliation_date: reconciliation_date, closing_balance: closing_balance, items_attributes: items_attributes)
end