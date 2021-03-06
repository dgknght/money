# == Schema Information
#
# Table name: accounts
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  account_type     :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  balance          :decimal(, )      default(0.0), not null
#  entity_id        :integer          not null
#  parent_id        :integer
#  content_type     :string(20)
#  cost             :decimal(, )      default(0.0), not null
#  gains            :decimal(, )      default(0.0), not null
#  value            :decimal(, )      default(0.0), not null
#  children_balance :decimal(, )      default(0.0), not null
#  children_cost    :decimal(, )      default(0.0), not null
#  children_gains   :decimal(, )      default(0.0), not null
#  children_value   :decimal(, )      default(0.0), not null
#

class Account < ActiveRecord::Base
  belongs_to :entity, inverse_of: :accounts
  belongs_to :parent, class_name: 'Account', inverse_of: :children
  has_many :children, -> { order :name }, class_name: 'Account', inverse_of: :parent, foreign_key: 'parent_id'
  has_many :reconciliations, -> { order :reconciliation_date }, inverse_of: :account, autosave: true
  has_many :transaction_items, inverse_of: :account
  has_many :lots
  has_many :budget_items
  has_many :budget_monitors

  START_OF_TIME = Chronic.parse('1000-01-01').to_date
  END_OF_TIME = Chronic.parse('9999-12-31').to_date
  CONTENT_TYPES = %w(currency commodities commodity)

  class << self
    CONTENT_TYPES.each do |type|
      define_method "#{type}_content" do
        type
      end
    end
  end

  CONTENT_TYPES.each do |type|
    define_method "#{type}?" do
      self.content_type == type
    end
  end

  LEFT_SIDE = %w(asset expense)
  RIGHT_SIDE = %w(liability equity income)
  ACCOUNT_TYPES = LEFT_SIDE + RIGHT_SIDE
  
  class << self
    ACCOUNT_TYPES.each do |type|
      define_method "#{type}_type" do
        type
      end
    end
  end

  ACCOUNT_TYPES.each do |type|
    define_method "#{type}?" do
      self.account_type == type
    end
  end

  BALANCE_FIELDS = %w(balance value cost gains)
  BALANCE_FIELDS.each do |field|
    define_method "recalculate_#{field}" do
      recalculate_field(field)
    end

    unless field == 'balance'
      define_method "recalculate_#{field}!" do
        recalculate_field(field)
        save!
      end
    end

    define_method "recalculate_children_#{field}" do
      recalculate_children_field(field)
    end

    define_method "recalculate_children_#{field}!" do
      recalculate_children_field(field)
      save!
    end
  end

  validates :name, presence: true,
                   uniqueness: { scope: [:entity, :parent] }
  validates :account_type, presence: true, 
                           inclusion: { in: ACCOUNT_TYPES }
  validates :content_type, presence: true,
                           inclusion: { in: CONTENT_TYPES }
  validate :parent_must_have_same_type
  
  before_validation :set_defaults

  scope :base, -> { order(:name) }
  scope :root, -> { base.where(parent_id: nil) }
  scope :asset, -> { base.where(account_type: Account.asset_type) }
  scope :commodities, -> { asset.where(content_type: Account.commodities_content) }
  scope :liability, -> { base.where(account_type: Account.liability_type) }
  scope :equity, -> { base.where(account_type: Account.equity_type) }
  scope :income, -> { base.where(account_type: Account.income_type) }
  scope :expense, -> { base.where(account_type: Account.expense_type) }
  
  def all_children
    children.reduce([]) { |array, child| array + child.children }
  end

  def as_json(options)
    super({ methods: [:depth, :path] })
  end
  def balance_as_of(date)
    balance_between START_OF_TIME, date
  end
  
  def balance_between(start_date, end_date)
    basis_item = transaction_items.joins(:owning_transaction).where('transactions.transaction_date < ?', start_date).order('transaction_items."index" DESC').first
    last_item = transaction_items.joins(:owning_transaction).where('transactions.transaction_date <= ?', end_date).order('transaction_items."index" DESC').first
    return (last_item.try(:balance) || 0) - (basis_item.try(:balance) || 0)
  end
  
  def balance_with_children
    balance + children_balance
  end

  def balance_with_children_as_of(date)
    children.reduce( self.balance_as_of(date) ) { |sum, child| sum += child.balance_with_children_as_of(date) }
  end
  
  def balance_with_children_between(start_date, end_date)
    children.reduce( self.balance_between(start_date, end_date) ) { |sum, child| sum += child.balance_between(start_date, end_date) }
  end

  def cost_as_of(date)
    return balance_as_of(date) unless commodity?
    lots.reduce(0){|sum, lot| sum + lot.cost_as_of(date)}
  end

  def cost_with_children
    cost + children_cost
  end

  def cost_with_children_as_of(date)
    children.reduce(cost_as_of(date)) { |sum, child| sum + child.cost_with_children_as_of(date) }
  end

  # Adjusts the balance of the account by the specified amount
  def credit(amount)
    delta = (amount * polarity(TransactionItem.credit))
    update_local_balances(delta)
  end
  
  def credit!(amount)
    credit(amount)
    save!
    balance
  end
  
  # Adjusts the balance of the account by the specified amount
  def debit(amount)
    delta = (amount * polarity(TransactionItem.debit))
    update_local_balances(delta)
  end
  
  def debit!(amount)
    debit(amount)
    save!
    balance
  end
  
  # returns the number of parents in the parent-child chain
  def depth
    parent ? parent.depth + 1 : 0
  end

  def self.find_by_path(path)
    segments = path.is_a?(String) ? path.split('/') : path
    segments.reduce(nil){|p, n| (p.try(:children) || Account).find_by_name(n)}
  end

  def first_transaction_item_occurring_before(date)
    ids = transaction_items.
      occurring_before(date).
      map(&:id).
      take(1)
    TransactionItem.find(ids).first
  end

  def gains_as_of(date)
    value_as_of(date) - cost_as_of(date)
  end

  def gains_with_children
    gains + children_gains
  end

  def gains_with_children_as_of(date)
    children.reduce(gains_as_of(date)) { |sum, child| sum + child.gains_with_children_as_of(date) }
  end

  def infer_action(amount)
    if left_side?
      amount < 0 ? TransactionItem.credit : TransactionItem.debit
    else
      amount < 0 ? TransactionItem.debit : TransactionItem.credit
    end
  end

  def parent_name
    parent ? parent.name : nil
  end

  def parents
    if parent
      [parent] + parent.parents
    else
      []
    end
  end

  def path
    parent ? "#{parent.path}/#{name}" : name
  end
  
  def polarity(action)
    return -1 if (action == TransactionItem.credit && left_side?) || (action == TransactionItem.debit && right_side?)
    1
  end

  def recalculate_balance
    recalculate_balance!
  end

  def recalculate_balance!(options = {})
    options = { rebuild_item_indexes: false }.merge(options || {})
    if options[:rebuild_item_indexes]
      last_index = -1
      last_balance = BigDecimal.new(0)
      all_items_sorted_by_date.each do |item|
        last_index = item.index = (last_index + 1)
        last_balance = item.balance = (last_balance + item.polarized_amount)
        item.save!
      end
      self.balance = last_balance
    else
      self.balance = balance_as_of(END_OF_TIME)
    end
    save!
  end

  def recalculate_children_field(field)
    new_value = children.reduce(0){|sum, c| sum + c.send("#{field}_with_children")}
    send("children_#{field}=", new_value)
  end

  def recalculate_balances!(opts = {})
    return if entity.suspend_balance_recalculations

    children_balances_only = opts.fetch(:children_balances_only, false)
    recalculation_fields(opts).each do |field|
      send("recalculate_#{field}") unless children_balances_only
      recalculate_children_field field
    end
    save!
    parent.recalculate_balances!(opts.merge(children_balances_only: true)) if parent && !opts.fetch(:suppress_bubbling, false)
  end

  def root?
    self.parent_id.nil?
  end

  def shares
    shares_as_of(Time.now.utc)
  end

  def shares_as_of(date)
    date = ensure_date(date)
    lots.
      select{|l| l.purchase_date <= date}.
      reduce(0){|sum, lot| sum + lot.shares_as_of(date)}
  end

  # Value is the current value of the account. For cash accounts
  # this will always be the same as the balance. For commodity
  # accounts, this will be the sum of the values of the lots
  def value_as_of(date)
    date = ensure_date(date)
    return balance_as_of(date) unless commodity?
    price = nearest_price(date)
    shrs = shares_as_of(date)
    price && shrs ? shrs * price : 0
  end

  def value_with_children
    value + children_value
  end

  def value_with_children_as_of(date)
    date = ensure_date(date)
    children.reduce(value_as_of(date)){|sum, child| sum + child.value_with_children_as_of(date)}
  end

  def nearest_price(date)
    date = ensure_date(date)
    commodity = entity.commodities.find_by_symbol(name)
    commodity.prices.
      sort{|p1, p2| p2.trade_date <=> p1.trade_date}.
      select{|p| p.trade_date <= date}.
      map(&:price).
      first
  end

  def left_side?
    LEFT_SIDE.include?(account_type)
  end

  def right_side?
    RIGHT_SIDE.include?(account_type)
  end

  def transaction_items_occurring_between(start_date, end_date)
    ids = transaction_items.
      occurring_between(start_date, end_date).
      map(&:id)
    TransactionItem.find(ids)
  end

  def transaction_items_occurring_on_or_after(date)
    ids = transaction_items.
      occurring_on_or_after(date).
      map(&:id)
    TransactionItem.find(ids)
  end

  memoize [
    :balance_as_of,
    :balance_with_children_as_of,
    :cost_as_of,
    :cost_with_children_as_of,
    :gains_as_of,
    :gains_with_children_as_of,
    :shares_as_of,
    :value_as_of,
    :value_with_children_as_of,
    :nearest_price
  ], ttl: 5.minutes

  private

  def all_items_sorted_by_date
    # TODO Probably want to do this in batches
    ids = transaction_items.
      joins(:owning_transaction).
      order('transactions.transaction_date asc, transaction_items."index" asc').
      reduce({}){|result, item| result[item.id] = result.count; result}
    # The above joins to the transaction table for sorting purposes, 
    # but returns a list of frozen records.
    # The below returns editable records, but ignores the order.
    # The hash map is used to preserve the order with the editable items
    TransactionItem.find(ids.keys).sort_by{|item| ids[item.id]}
  end

    def sum_of_credit_transaction_items(start_date, end_date)
      result = transaction_items.
        joins(:owning_transaction).
        where("action=? and transactions.transaction_date >= ? and transactions.transaction_date <= ?", TransactionItem.credit, start_date, end_date).
        sum(:amount)
    end
    
    def sum_of_debit_transaction_items(start_date, end_date)
      result = transaction_items.
        joins(:owning_transaction).
        where("action=? and transactions.transaction_date >= ? and transactions.transaction_date <= ?", TransactionItem.debit, start_date, end_date).
        sum(:amount)
    end
    
    def ensure_date(date)
      return Date.parse(date) if date.is_a?(String)
      return date.to_date if date.respond_to?(:to_date)
      date
    end
    
    def parent_is_same_type?
      parent_id.nil? || parent.account_type == self.account_type
    end
    
    def parent_must_have_same_type
      errors.add(:parent_id, 'must have the same account type') unless parent_is_same_type?
    end

    def recalculation_fields(opts)
      all_fields = %w(balance value cost gains)
      if opts[:only]
        Array(opts[:only])
      elsif opts[:except]
        except = Array(opts[:except])
        all_fields.reject{|f| except.include?(f)}
      else
        all_fields
      end
    end

    # Recalculates the fields :value, :cost, :gains
    def recalculate_field(field)
      method = "#{field}_as_of".to_sym
      current = send(method, END_OF_TIME)
      send("#{field}=", current)
    end

    def set_defaults
      self.content_type ||= Account.currency_content
    end

    def update_local_balance(field, delta)
      new_value = send(field) + delta
      send("#{field}=", new_value)
    end

    def update_local_balances(delta)
      %w(balance cost value).each do |field|
        update_local_balance(field, delta)
      end
      parent.recalculate_balances!(children_balances_only: true) if parent
      balance
    end
end
