# == Schema Information
#
# Table name: accounts
#
#  id                    :integer          not null, primary key
#  name                  :string(255)      not null
#  account_type          :string(255)      not null
#  created_at            :datetime
#  updated_at            :datetime
#  balance               :decimal(, )      default(0.0), not null
#  entity_id             :integer          not null
#  parent_id             :integer
#  content_type          :string(20)
#  cost                  :decimal(, )      default(0.0), not null
#  gains                 :decimal(, )      default(0.0), not null
#  value                 :decimal(, )      default(0.0), not null
#  balance_with_children :decimal(, )      default(0.0), not null
#  cost_with_children    :decimal(, )      default(0.0), not null
#  gains_with_children   :decimal(, )      default(0.0), not null
#  value_with_children   :decimal(, )      default(0.0), not null
#

class Account < ActiveRecord::Base
  belongs_to :entity, inverse_of: :accounts
  belongs_to :parent, class_name: 'Account', inverse_of: :children
  has_many :children, -> { order :name }, class_name: 'Account', inverse_of: :parent, foreign_key: 'parent_id'
  has_many :reconciliations, -> { order :reconciliation_date }, inverse_of: :account, autosave: true
  has_many :transaction_items
  has_many :lots
  has_many :budget_items
  has_many :budget_monitors

  END_OF_TIME = Chronic.parse('9999-12-31')
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
    super({ methods: :depth })
  end
  
  def balance_as_of(date)
    balance_between Date.civil(1000, 1, 1), date
  end
  
  def balance_between(start_date, end_date)
    start_date = ensure_date(start_date)
    end_date = ensure_date(end_date)
    
    sum_of_credits = sum_of_credit_transaction_items(start_date, end_date)
    sum_of_debits = sum_of_debit_transaction_items(start_date, end_date)
    
    if left_side?
      sum_of_debits - sum_of_credits
    else
      sum_of_credits - sum_of_debits
    end
  end
  
  def balance_with_children_as_of(date)
    children.reduce( self.balance_as_of(date) ) { |sum, child| sum += child.balance_as_of(date) }
  end
  
  def balance_with_children_between(start_date, end_date)
    children.reduce( self.balance_between(start_date, end_date) ) { |sum, child| sum += child.balance_between(start_date, end_date) }
  end
  
  def children_cost
    children.reduce(0) { |sum, child| sum + child.cost }
  end

  def children_value
    children.reduce(0) { |sum, child| sum + child.value }
  end

  def cost_as_of(date)
    return balance_as_of(date) unless commodity?
    lots.reduce(0){|sum, lot| sum + lot.cost_as_of(date)}
  end

  def cost_with_children_as_of(date)
    return children.reduce(cost_as_of(date)) { |sum, child| sum + child.cost_with_children_as_of(date) }
  end

  # Adjusts the balance of the account by the specified amount
  def credit(amount)
    delta = (amount * polarity(TransactionItem.credit))
    update_local_balances(delta)
  end
  
  def credit!(amount)
    credit(amount)
    save!
  end
  
  # Adjusts the balance of the account by the specified amount
  def debit(amount)
    delta = (amount * polarity(TransactionItem.debit))
    update_local_balances(delta)
  end
  
  def debit!(amount)
    debit(amount)
    save!
  end
  
  # returns the number of parents in the parent-child chain
  def depth
    parent ? parent.depth + 1 : 0
  end

  def self.find_by_path(path)
    segments = path.is_a?(String) ? path.split('/') : path
    segments.reduce(nil){|p, n| (p.try(:children) || Account).find_by_name(n)}
  end

  def gains_as_of(date)
    value_as_of(date) - cost_as_of(date)
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

  def path
    parent ? "#{parent.path}/#{name}" : name
  end
  
  def polarity(action)
    return -1 if (action == TransactionItem.credit && left_side?) || (action == TransactionItem.debit && right_side?)
    1
  end

  def recalculate_balances(opts = {})
    with_children_only = opts.fetch(:with_children_only, false)
    recalculation_fields(opts).each do |field|
      recalculate_field(field) unless with_children_only
      recalculate_field("#{field}_with_children")
    end
    parent.recalculate_balances(opts.merge(with_children_only: true)) if parent
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
      reduce(0){|sum, lot| sum + lot.shares_owned}
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

  def value_with_children_as_of(date)
    date = ensure_date(date)
    children.reduce(value_as_of(date)){|sum, child| sum + child.value_with_children_as_of(date)}
  end

  def nearest_price(date)
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

  private
    def sum_of_credit_transaction_items(start_date, end_date)
      result = transaction_items.
        joins(:transaction).
        where("action=? and transactions.transaction_date >= ? and transactions.transaction_date <= ?", TransactionItem.credit, start_date, end_date).
        sum(:amount)
    end
    
    def sum_of_debit_transaction_items(start_date, end_date)
      result = transaction_items.
        joins(:transaction).
        where("action=? and transactions.transaction_date >= ? and transactions.transaction_date <= ?", TransactionItem.debit, start_date, end_date).
        sum(:amount)
    end
    
    def ensure_date(date)
      return Date.parse(date) if date.is_a?(String)
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

    def recalculate_field(field)
      # Assume that most of the time the balance 
      # will not need to be updated
      method = "#{field}_as_of".to_sym
      current = send(method, END_OF_TIME)
      update_attribute(field, current) unless current == send(field)
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
        update_local_balance("#{field}_with_children", delta)
      end
      parent.recalculate_balances(with_children_only: true) if parent
    end
end
