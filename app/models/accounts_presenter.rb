require 'accounts_presenter/account_record_adapter'
require 'accounts_presenter/account_summary_record'

# Organizes and summary account information
# for display
class AccountsPresenter
  include Enumerable

  def as_json(options)
    @entity.accounts.as_json(options)
  end

  DisplayRecord = Struct.new(:caption, :balance, :depth, :account) do
    def identifier
      "adjustement_#{caption.gsub(/\s/, '')}"
    end
  end

  def each
    asset = summary(:asset, 'Assets')
    liability = summary(:liability, 'Liabilities')

    equity = summary(:equity, 'Equity')
    equity << unrealized_gains
    equity << balancing_record(asset.balance, liability.balance, equity.balance) 

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

  def summary(method, caption) 
    accounts = @entity.accounts.root.send(method)
    records = accounts_to_adapters(accounts)
    AccountSummaryRecord.new(caption, records)
  end

  def to_a(*summaries)
    summaries.reduce([]) do |list, record|
      list + record.to_a
    end
  end

  def unrealized_gains
    amount = @entity.unrealized_gains
    DisplayRecord.new('Unrealized gains', amount, 1) unless amount == 0
  end
end
