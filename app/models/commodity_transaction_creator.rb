class CommodityTransactionCreator
  include ActiveModel::Validations

  ACTIONS = %w(buy sell)

  attr_accessor :transaction_date, :symbol, :action, :shares, :value

  validates_presence_of :symbol
  validates :shares, presence: true, numericality: true
  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :value, presence: true, numericality: true

  def initialize(account, attributes = {})
    attr = (attributes || {}).with_indifferent_access
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
end
