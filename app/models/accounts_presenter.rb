# Organizes and summaries account information
# for display
class AccountsPresenter
  include Enumerable

  DisplayRecord = Struct.new(:caption, :balance, :depth)
  def each
    assets = summaries(:asset, 'Assets')
    liabilities = summaries(:liability, 'Liabilities')
    equity = summaries(:equity, 'Equity')
    balancer = balancing_record(assets.first.balance, liabilities.first.balance) 
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

  def balancing_record(total_assets, total_liabilities)
    difference = total_assets - total_liabilities
    DisplayRecord.new('Retained earnings', difference, 1) if difference != 0
  end

  def sum(items)
    items.reduce(0) { |sum, item| sum + item.balance }
  end

  def summaries(method, caption) 
    accounts = @entity.accounts.send(method)
    total = sum(accounts)
    [
      DisplayRecord.new(caption, total, 0),
      accounts.map { |a| DisplayRecord.new(a.name, a.balance, 1) }
    ]
  end
end
