class CommodityTransactionCreator
  include ActiveModel::Validations

  #TODO Need to be able to configure this
  LONG_TERM_GAINS_NAMES = ['Long Term Gains', 'Long-term capital gains']
  SHORT_TERM_GAINS_NAMES = ['Short Term Gains', 'Short-term capital gains']
  INVESTMENT_EXPENSE_NAMES = ['Investment Expenses']

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

  attr_accessor :account_id, :commodities_account_id, :transaction_date, :symbol, :action, :shares, :value, :valuation_method, :fee

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
  validates_numericality_of :fee

  def account
    @account ||= find_account(account_id)
  end

  def account=(account)
    @account = account
    self.account_id = account.nil? ? nil : account.id
  end

  def as_json(options)
    {
      transaction: @transaction.as_json(options),
      lots: lots.as_json(options)
    }
  end

  def commodities_account
    @commodities_account ||= (find_account(commodities_account_id) || account)
  end

  def commodities_account=(account)
    @commodities_account = account
    self.commodities_account_id = account.nil? ? nil : account.id
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
    self.commodities_account_id = attr[:commodities_account_id] if attr[:commodities_account_id]
    self.commodities_account = attr[:commodities_account] if attr[:commodities_account]
    self.transaction_date = to_date(attr[:transaction_date]) || Date.today
    self.action = attr[:action]
    self.symbol = attr[:symbol]
    self.shares = BigDecimal.new(attr[:shares], 4) if attr[:shares]
    self.value = BigDecimal.new(attr[:value], 4) if attr[:value]
    self.valuation_method = attr[:valuation_method] || default_valuation_method
    self.fee = attr.fetch(:fee, 0)
  end

  def inspect
    "<CommodityTransactionCreator: @account=#{account.name} @shares=#{shares.to_f} @price=#{price.to_f} @value=#{value.to_f} @symbol=#{symbol} @transaction_date=#{transaction_date}>"
  end

  def price
    return nil if value.nil? || shares.nil?
    value.to_f / shares.to_f
  end

  private

  def add_balance_sheet_items(transaction, cost_of_shares_sold)
    # account
    account_item = transaction.items.new(account: account,
                                         action: TransactionItem.debit,
                                         amount: value - numeric_fee)
    # commodity
    transaction.items.new(account: commodity_account,
                          action: TransactionItem.credit,
                          amount: cost_of_shares_sold)
  end

  def add_income_expense_items(transaction, st_gains, lt_gains)
    add_inferred_action_item transaction, long_term_gains_account, lt_gains
    add_inferred_action_item transaction, short_term_gains_account, st_gains
    transaction.items.new(account: investment_expense_account,
                          amount: fee,
                          action: TransactionItem.debit) unless numeric_fee.zero?
  end

  def add_inferred_action_item(transaction, account, amount)
    return unless amount != 0
    transaction.items.new(account: account,
                          action: account.infer_action(amount),
                          amount: amount.abs)
  end

  def add_sell_transaction_items(transaction, sale_results)
    cost_of_shares_sold, st_gain, lt_gain = calculate_gains(sale_results)
    add_balance_sheet_items transaction, cost_of_shares_sold
    add_income_expense_items transaction, st_gain, lt_gain
  end

  def calculate_gains(sale_results)
    lt_gain = st_gain = cost_of_shares_sold = 0
    sale_results.each do |result|
      cost = (result.shares * result.lot.price)
      proceeds = (result.shares * price)
      gain = proceeds - cost
      cost_of_shares_sold += cost
      if held_more_than_one_year?(result.lot.purchase_date)
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
    transaction = account.entity.transactions.new(transaction_date: transaction_date,
                                                  description: purchase_description)

    # Debit the account that tracks the value of the commodity
    transaction.items << TransactionItem.new(account: commodity_account,
                                             amount: value,
                                             action: TransactionItem.debit)

    # Debit the investment expense account, if a fee is present
    transaction.items << TransactionItem.new(account: investment_expense_account,
                                             amount: numeric_fee,
                                             action: TransactionItem.debit) unless numeric_fee.zero?

    # Credit the account used to fund the purchase
    transaction.items << TransactionItem.new(account: account,
                                             amount: value + numeric_fee,
                                             action: TransactionItem.credit)
    transaction.save!
    transaction
  end

  def create_commodity_account(symbol)
    commodities_account.children.create!(name: symbol,
                                         account_type: Account.asset_type,
                                         content_type: Account.commodity_content,
                                         entity: account.entity)
  end

  def create_price_record
    Price.put_price(commodity, transaction_date, price)
  end

  def create_sell_transaction(sale_results)
    transaction = account.entity.transactions.new(transaction_date: transaction_date,
                                                  description: sale_description)
    add_sell_transaction_items transaction, sale_results
    transaction.save!
    transaction
  rescue StandardError => e
    Rails.logger.error "Unable to create the transaction for the commodity sale:\n  #{transaction.errors.full_messages.to_sentence}\n  transaction=#{transaction.inspect}\n  items=#{transaction.items.map{|i| i.inspect}.join("\n    ")}"
    raise e
  end

  def find_account(id)
    return nil unless id
    Account.find(id)
  end

  def find_first_account_with_name(names)
    names.lazy.
      map{|name| account.entity.accounts.find_by_name(name)}.
      select{|a| a}.
      first
  end

  def find_long_term_gains_account
    find_first_account_with_name(LONG_TERM_GAINS_NAMES)
  end

  def find_short_term_gains_account
    find_first_account_with_name(SHORT_TERM_GAINS_NAMES)
  end

  def find_or_create_commodity_account
    commodities_account.children.where(name: symbol).first || create_commodity_account(symbol)
  end

  def long_term_gains_account
    @long_term_gains_account ||= find_long_term_gains_account
    raise 'Long term gains account not found' unless @long_term_gains_account
    @long_term_gains_account
  end

  def lots
    @lots ||= []
  end

  def held_more_than_one_year?(purchase_date)
    year = purchase_date.year + 1
    month, day = (purchase_date.month == 2 && purchase_date.day == 29) ?
      [3, 1] :
      [purchase_date.month, purchase_date.day]

    one_year_later = Date.new(year, month, day)
    transaction_date >= one_year_later
  end

  def investment_expense_account
    find_first_account_with_name(INVESTMENT_EXPENSE_NAMES) || raise("Unable to find an account with these names: #{INVESTMENT_EXPENSE_NAMES.join(', ')}")
  end

  def numeric_fee
    BigDecimal.new(fee)
  end

  def process_buy
    transaction = create_buy_transaction
    lots << process_buy_lot(transaction)
    create_price_record
    transaction
  end

  def process_buy_lot(transaction)
    lot = commodity_account.lots.create!(commodity: commodity,
                               shares_owned: shares,
                               price: price,
                               purchase_date: transaction_date)
    # Should this action trigger the above action?
    lot_transaction = lot.transactions.create!(transaction: transaction, 
                                               shares_traded: shares,
                                               price: price)
    lot
  end

  def process_sell
    sale_results = process_sell_lots
    sale_results.each{ |r| lots << r.lot }
    transaction = create_sell_transaction(sale_results)
    sale_results.each do |result|
      result.lot.transactions.create!(transaction: transaction,
                                      shares_traded: -result.shares,
                                      price: price)
    end
    create_price_record
    transaction
  end

  def process_sell_lots
    shares_to_remove = shares
    result = []
    lots = fifo? ? commodity_account.lots.fifo : commodity_account.lots.filo
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

  def purchase_description
    "Purchase #{shares} share(s) of #{symbol} at #{"%.4f" % price}"
  end

  def short_term_gains_account
    @short_term_gains_account ||= find_short_term_gains_account
    raise 'Short term gains account not found' unless @short_term_gains_account
    @short_term_gains_account
  end

  def can_find_commodity
    errors.add(:symbol, "does not refer to an existing commodity") unless commodity
  end

  def sale_description
    "Sell #{shares} share(s) of #{symbol} at #{"%.4f" % price}"
  end

  def to_date(value)
    return nil unless value
    return value.to_date if value.respond_to?(:to_date)
    Chronic.parse(value)
  end

  def value_is_not_zero
    return unless value == 0
    errors.add(:value, 'cannot be zero')
  end
end
