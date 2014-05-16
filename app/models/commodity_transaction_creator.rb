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
      transaction = buy? ? process_buy : process_sell
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

  def capital_gains_account
    #TODO Need to be able to configure this
    @capital_gains_account ||= account.entity.accounts.find_by_name('Short-term capital gains')
  end

  def commodity_account
    @commodity_account || find_or_create_commodity_account
  end

  def create_buy_transaction
    attributes = {
      transaction_date: transaction_date,
      description: "Purchase shares of #{symbol}",
      other_account: commodity_account,
      amount: -value
    }
    TransactionItemCreator.new(account, attributes).create!.transaction
  end

  def create_commodity_account(symbol)
    account.children.create!(name: symbol,
                             account_type: Account.asset_type,
                             entity: account.entity)
  end

  def create_sell_transaction(lot)
    cost_of_shares_sold = lot.price * shares
    gain_loss = value - cost_of_shares_sold

    #   credit the asset account that tracks money spent on the specified commodity
    #   debit the specified account (cash held in the investment account)
    transaction = account.entity.transactions.new(transaction_date: transaction_date,
                                                  description: "Sell shares of #{symbol}")
    account_item = transaction.items.new(account: account,
                                         action: account.infer_action(value),
                                         amount: value)
    commodity_account_item = transaction.items.new(account: commodity_account,
                                                   action: TransactionItem.opposite_action(account_item.action),
                                                   amount: cost_of_shares_sold)
    if gain_loss != 0
      gain_item = transaction.items.new(account: capital_gains_account,
                                        action: capital_gains_account.infer_action(gain_loss),
                                        amount: gain_loss.abs)
    end

    transaction.save!
    transaction
  end

  def find_account
    return nil unless account_id
    Account.find(account_id)
  end

  def find_or_create_commodity_account
    account.children.where(name: symbol).first || create_commodity_account(symbol)
  end

  def process_buy
    transaction = create_buy_transaction
    process_buy_lot(transaction)
    transaction
  end

  def process_buy_lot(transaction)
    lot = account.lots.create!(commodity: commodity,
                               shares_owned: shares,
                               price: price,
                               purchase_date: transaction_date)
    # Should this action trigger the above action?
    lot_transaction = lot.transactions.create!(transaction: transaction, 
                                               shares_traded: shares,
                                               price: price)
  end

  def process_sell
    lot = process_sell_lot
    transaction = create_sell_transaction(lot)
    lot.transactions.create!(transaction: transaction, shares_traded: -shares, price: price)
    transaction
  end

  def process_sell_lot
    # assume FIFO for now, need to decide how to store that
    lot = account.lots.where('shares_owned > 0').order('purchase_date DESC').first
    raise 'Not lot found' unless lot

    # TODO handle situation where shares > shares_owned
    lot.shares_owned -= shares
    lot.save!

    #TODO should this trigger the change in the lot itself?
    lot
  end
end
