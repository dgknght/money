# Organizes and summaries account information
# for display
class AccountsPresenter
  include Enumerable

  DisplayRecord = Struct.new(:caption, :balance, :depth)
  def each
    assets = summaries(:asset, 'Assets')
    liabilities = summaries(:liability, 'Liabilities')
    equity = summaries(:equity, 'Equity')
    balancer = balancing_record(assets.first.balance, liabilities.first.balance, equity.first.balance) 
    if balancer
      equity << balancer
      equity.first.balance += balancer.balance
    end
    income = summaries(:income, 'Income')
    expense = summaries(:expense, 'Expense')
    (assets + liabilities + equity + income + expense).
      flatten.
      each { |r| yield r }
  end

  def initialize(entity)
    raise 'Must specify an entity' unless entity && entity.respond_to?(:accounts)
    @entity = entity
  end

  private

  def account_summaries(accounts, depth = 1)
    accounts.map do |a|
      [DisplayRecord.new(a.name, a.balance_with_children, depth)] +
        account_summaries(a.children, depth + 1)
    end
  end

  def balancing_record(total_assets, total_liabilities, total_equity)
    difference = total_assets - (total_liabilities + total_equity)
    DisplayRecord.new('Retained earnings', difference, 1) if difference != 0
  end

  def sum(items)
    items.reduce(0) { |sum, item| sum + item.balance_with_children }
  end

  def summaries(method, caption) 
    accounts = @entity.accounts.send(method)
    total = sum(accounts)
    [
      DisplayRecord.new(caption, total, 0),
      account_summaries(accounts)
    ]
  end
end
