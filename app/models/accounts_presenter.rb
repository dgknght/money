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

    income = summary(:income, 'Income')
    expense = summary(:expense, 'Expense')

    equity << unrealized_gains
    equity << retained_earnings(income.balance, expense.balance)

    to_a(asset, liability, equity, income, expense).each do |r|
      yield r if include_record?(r)
    end
  end

  # Options:
  #   hide_zero_balances: when true, causes accounts with a balance of zero to be excluded
  def initialize(entity, options = {})
    raise 'Must specify an entity' unless entity && entity.respond_to?(:accounts)
    @entity = entity
    @hide_zero_balances = options.fetch(:hide_zero_balances, false)
    @hide_commodity_accounts = options.fetch(:hide_commodity_accounts, true)
  end

  private

  def root_accounts(account_type)
    account_type = account_type.to_s
    all_accounts.
      select{|a| a.root? && a.account_type == account_type}.
      sort_by(&:name)
  end

  def all_accounts
    @all_accounts ||= @entity.accounts.to_a
  end

  def account_to_adapters(account, depth)
    [AccountRecordAdapter.new(account, depth)] + accounts_to_adapters(children(account), depth + 1)
  end

  def accounts_to_adapters(accounts, depth)
    accounts.reduce([]) { |list, account| list + account_to_adapters(account, depth) }
  end

  def children(account)
    all_accounts.select{|a| a.parent_id == account.id}
  end

  def include_record?(record)
    filters = []
    filters << ->(r) {r.balance.zero?} if @hide_zero_balances
    filters << ->(r) {r.account.try(:commodity?) || false} if @hide_commodity_accounts
    filters.none?{|f| f(record)}
  end

  def retained_earnings(total_income, total_expense)
    difference = total_income - total_expense
    DisplayRecord.new('Retained earnings', difference, 1) if difference != 0
  end

  def summary(type, caption)
    accounts = root_accounts(type)
    records = accounts_to_adapters(accounts, 1)
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
