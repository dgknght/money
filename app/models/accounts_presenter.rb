require 'accounts_presenter/account_record_adapter'
require 'accounts_presenter/account_summary_record'

# Organizes and summary account information
# for display
class AccountsPresenter
  include Enumerable

  DisplayRecord = Struct.new(:caption, :balance, :depth)
  def each
    asset = summary(:asset, 'Assets')
    liability = summary(:liability, 'Liabilities')
    equity = summary(:equity, 'Equity')
    balancer = balancing_record(asset.balance, liability.balance, equity.balance) 
    equity << balancer if balancer
    income = summary(:income, 'Income')
    expense = summary(:expense, 'Expense')

    to_a(asset, liability, equity, income, expense).each { |r| yield r }
  end

  def initialize(entity)
    raise 'Must specify an entity' unless entity && entity.respond_to?(:accounts)
    @entity = entity
  end

  private

  def account_to_adapters(account)
    [AccountRecordAdapter.new(account)] + accounts_to_adapters(account.children)
  end

  def accounts_to_adapters(accounts)
    accounts.reduce([]) { |list, account| list + account_to_adapters(account) }
  end

  def balancing_record(total_assets, total_liabilities, total_equity)
    difference = total_assets - (total_liabilities + total_equity)
    DisplayRecord.new('Retained earnings', difference, 1) if difference != 0
  end

  def sum(items)
    items.reduce(0) { |sum, item| sum + item.balance_with_children }
  end

  def summary(method, caption) 
    accounts = @entity.accounts.send(method)
    records = accounts_to_adapters(accounts)
    AccountSummaryRecord.new(caption, records)
  end

  def to_a(*summaries)
    summaries.reduce([]) do |list, record|
      list + record.to_a
    end
  end
end
