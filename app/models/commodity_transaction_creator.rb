class CommodityTransactionCreator
  include ActiveModel::Validations

  ACTIONS = %w(buy sell)

  attr_accessor :account_id, :transaction_date, :symbol, :action, :shares, :value

  validates_presence_of :symbol, :account_id
  validates :shares, presence: true, numericality: true
  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :value, presence: true, numericality: true

  def account
    @account ||= find_account
  end

  def account=(account)
    @account = account
    self.account_id = account.nil? ? nil : account.id
  end

  def create
    return nil unless valid?
  end

  def create!
    raise "Instance is invalid: #{errors.full_messages.join(', ')}" unless valid?
  end

  def initialize(attributes = {})
    attr = (attributes || {}).with_indifferent_access
    self.account_id = attr[:account_id]
    self.transaction_date = attr.get_date(:transaction_date) || Date.today
    self.action = attr[:action]
    self.symbol = attr[:symbol]
    self.shares = attr[:shares]
    self.value = attr[:value]
  end

  def price
    return nil if value.nil? || shares.nil?
    value / shares
  end

  private

  def find_account
    return nil unless account_id
    Account.find(account_id)
  end
end
