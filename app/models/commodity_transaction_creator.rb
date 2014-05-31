class CommodityTransactionCreator
  include ActiveModel::Validations

  VALUATION_METHODS = %w(fifo filo)
  class << self
    VALUATION_METHODS.each do |m|
      define_method m do
        m
      end
    end
  end
  VALUATION_METHODS.each do |m|
    define_method "#{m}?" do
      valuation_method.to_sym == m.to_sym
    end
  end

  ACTIONS = %w(buy sell)
  class << self
    ACTIONS.each do |a|
      define_method a do
        a
      end
    end
  end

  attr_accessor :account_id, :transaction_date, :symbol, :action, :shares, :value, :valuation_method

  ACTIONS.each do |a|
    define_method "#{a}?" do
      action == a
    end
  end

  validates_presence_of :symbol, :account_id
  validates :shares, presence: true, numericality: { greater_than: 0 }
  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :value, presence: true, numericality: true
  validate :value_is_not_zero, :can_find_commodity

  def account
    @account ||= find_account
  end

  def account=(account)
    @account = account
    self.account_id = account.nil? ? nil : account.id
  end

  def as_json(options)
    { transaction: @transaction.as_json(options) }
  end

  def commodity
    @commodity ||= Commodity.find_by_symbol(symbol)
  end

  def create
    return nil unless valid?

    Account.transaction do
      @transaction = buy? ? process_buy : process_sell
    end
   @transaction 
  end

  def create!
    raise "Instance is invalid: #{errors.full_messages.join(', ')}" unless valid?
    create
  end

  def default_valuation_method
    :filo #TODO Make this configurable
  end

  def initialize(attributes = {})
    attr = (attributes || {}).with_indifferent_access
    self.account_id = attr[:account_id] if attr[:account_id]
    self.account = attr[:account] if attr[:account]
    self.transaction_date = to_date(attr[:transaction_date]) || Date.today
    self.action = attr[:action]
    self.symbol = attr[:symbol]
    self.shares = BigDecimal.new(attr[:shares], 4) if attr[:shares]
    self.value = BigDecimal.new(attr[:value], 4) if attr[:value]
    self.valuation_method = attr[:valuation_method] || default_valuation_method
  end

  def price
    return nil if value.nil? || shares.nil?
    value / shares
  end

  private

  def calculate_gains(sale_results)
    lt_gain = st_gain = cost_of_shares_sold = 0
    sale_results.each do |result|
      cost = (result.shares * result.lot.price)
      proceeds = (result.shares * price)
      gain = proceeds - cost

      cost_of_shares_sold += cost
      if more_than_a_year_ago?(result.lot.purchase_date)
        lt_gain += gain
      else
        st_gain += gain
      end
    end
    [cost_of_shares_sold, st_gain, lt_gain]
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

  def create_sell_transaction(sale_results)
    cost_of_shares_sold, st_gain, lt_gain = calculate_gains(sale_results)

    transaction = account.entity.transactions.new(transaction_date: transaction_date,
                                                  description: "Sell shares of #{symbol}")
    # account
    account_item = transaction.items.new(account: account,
                                         action: account.infer_action(value),
                                         amount: value)
    # commodity
    transaction.items.new(account: commodity_account,
                          action: TransactionItem.opposite_action(account_item.action),
                          amount: cost_of_shares_sold)
    # gain/loss
    if lt_gain != 0
      transaction.items.new(account: long_term_gains_account,
                            action: long_term_gains_account.infer_action(lt_gain),
                            amount: lt_gain.abs)
    end
    if st_gain != 0
      transaction.items.new(account: short_term_gains_account,
                            action: short_term_gains_account.infer_action(st_gain),
                            amount: st_gain.abs)
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

  def long_term_gains_account
    #TODO Need to be able to configure this
    @long_term_gains_account ||= account.entity.accounts.find_by_name('Long-term capital gains')
  end

  def more_than_a_year_ago?(purchase_date)
    one_year_later = Date.new(purchase_date.year + 1, purchase_date.month, purchase_date.day)
    transaction_date > one_year_later
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
    sale_results = process_sell_lots
    transaction = create_sell_transaction(sale_results)
    sale_results.each do |result|
      result.lot.transactions.create!(transaction: transaction,
                                      shares_traded: -result.shares,
                                      price: price)
    end
    transaction
  end

  def process_sell_lots
    shares_to_remove = shares
    result = []
    lots = fifo? ? account.lots.fifo : account.lots.filo
    lots.each do |lot|
      if shares_to_remove <= lot.shares_owned
        result << OpenStruct.new(shares: shares_to_remove,
                                 lot: lot)
        lot.shares_owned -= shares_to_remove
        shares_to_remove = 0
      else
        result << OpenStruct.new(shares: lot.shares_owned,
                                 lot: lot)
        shares_to_remove -= lot.shares_owned
        lot.shares_owned = 0
      end
      lot.save!

      break if shares_to_remove == 0
    end

    raise "Unable to find lots containing #{shares} share(s)" unless shares_to_remove == 0
    result
  end

  def short_term_gains_account
    #TODO Need to be able to configure this
    @short_term_gains_account ||= account.entity.accounts.find_by_name('Short-term capital gains')
  end

  def can_find_commodity
    errors.add(:symbol, "does not refer to an existing commodity") unless commodity
  end

  def to_date(value)
    return nil unless value
    return value.to_date if value.respond_to?(:to_date)
    Date.parse(value)
  end

  def value_is_not_zero
    return unless value == 0
    errors.add(:value, 'cannot be zero')
  end
end
