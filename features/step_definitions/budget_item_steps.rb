BUDGET = Transform(/^budget "([^"]+)"$/) do |name|
  budget = Budget.find_by_name(name)
  expect(budget).not_to be_nil
  budget
end

Given(/^(#{BUDGET}) allocates (#{DOLLAR_AMOUNT}) a month for "([^"]+)"$/) do |budget, amount, account_name|
  account = Account.find_by_name(account_name)
  expect(account).not_to be_nil
  budget_item = budget.items.new(account_id: account.id)
  distributor = BudgetItemDistributor.new(budget_item)
  distributor.method = BudgetItemDistributor.average
  distributor.options = { amount: amount}
  distributor.distribute
  budget_item.save!
end
