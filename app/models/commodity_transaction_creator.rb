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

    transaction = nil
    Account.transaction do
      transaction = create_currency_transaction
      process_lot(transaction)
    end
   transaction 
  end

  def create!
    raise "Instance is invalid: #{errors.full_messages.join(', ')}" unless valid?
    create
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

  def process_lot(transaction)
    # if buying
    #   record the purchase lot (# of shares, price, transaction date)
    # if selling
    #   find the lot for all shares being sold (always FILO or FIFO, probably need an entity-level configuration)
    #   subtract the sold shares from the found lots

    # Lot attributes
    # transaction_id
    # commodity_id
    # shares
    # price
    # value
  end

  def create_currency_transaction
    # if buying:
    #   debit an asset account that tracks money spent on the specified commodity
    #   credit the specified account (cash held in the investment account)
    #
    # if selling:
    #   credit the asset account that tracks money spent on the specified commodity
    #   debit the specified account (cash held in the investment account)
    #
    #   if the value is greater than the purchase value (see FIFO or FILO above)
    #     debit the capital gains account
    #   else
    #     credit the captial gains account
  end

  def find_account
    return nil unless account_id
    Account.find(account_id)
  end
end
