class CommodityTransactionCreator
  include ActiveModel::Validations

  ACTIONS = %w(buy sell)
  class << self
    ACTIONS.each do |a|
      define_method a do
        a
      end
    end
  end

  attr_accessor :account_id, :transaction_date, :symbol, :action, :shares, :value

  ACTIONS.each do |a|
    define_method "#{a}?" do
      action == a
    end
  end

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

  def commodity
    @commodity ||= Commodity.find_by_symbol(symbol)
  end

  def create
    return nil unless valid?

    transaction = nil
    Account.transaction do
      transaction = create_transaction
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

  def create_buy_transaction
    # debit an asset account that tracks money spent on the specified commodity
    debit_account = find_or_create_commodity_account(symbol)
    # credit the specified account (cash held in the investment account)
    credit_account = account
    attributes = {
      transaction_date: transaction_date,
      description: "Purchase shares of #{symbol}",
      other_account: debit_account,
      amount: -value
    }
    TransactionItemCreator.new(credit_account, attributes).create!.transaction
  end

  def create_commodity_account(symbol)
    account.children.create!(name: symbol,
                             account_type: Account.asset_type,
                             entity: account.entity)
  end

  def create_sell_transaction
    #   credit the asset account that tracks money spent on the specified commodity
    #   debit the specified account (cash held in the investment account)
    TransactionItemCreator.new(account, transaction_date: transaction_date,
                                        description: "Sell shares of #{symbol}",
                                        other_account: account.children.where(name: symbol),
                                        amount: value)
    #   if the value is greater than the purchase value (see FIFO or FILO above)
    #     debit the capital gains account
    #   else
    #     credit the captial gains account
  end

  def create_transaction
    if buy?
      create_buy_transaction
    else
      create_sell_transaction
    end
  end

  def find_account
    return nil unless account_id
    Account.find(account_id)
  end

  def find_or_create_commodity_account(symbol)
    account.children.where(name: symbol).first || create_commodity_account(symbol)
  end

  def process_lot(transaction)
    if buy?
      process_purchase_lot transaction
    else
      process_sale_lot transaction
    end
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

  def process_purchase_lot(transaction)
    lot = account.lots.create!(commodity: commodity,
                               shares_owned: shares,
                               price: price,
                               purchase_date: transaction_date)
    # Should this action trigger the above action?
    lot_transaction = lot.transactions.create!(transaction: transaction, 
                                               shares_traded: shares,
                                               price: price)
  end

end
