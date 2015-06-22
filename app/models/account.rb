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
  belongs_to :head_transaction_item, class_name: 'TransactionItem'
  belongs_to :first_transaction_item, class_name: 'TransactionItem'

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
  
  def balance_as_of(date, force_reload = false)
    # force_reload is a no-op here because there is no caching

    balance_between Date.civil(1000, 1, 1), date, force_reload
  end
  
  def balance_between(start_date, end_date, force_reload = false)
    # force_reload is a no-op here because there is no caching

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
  
  def balance_with_children_as_of(date, force_reload = false)
    # force_reload is a no-op here because there is no caching

    children.reduce( self.balance_as_of(date) ) { |sum, child| sum += child.balance_with_children_as_of(date) }
  end
  
  def balance_with_children_between(start_date, end_date, force_reload = false)
    # force_reload is a no-op here because there is no caching

    children.reduce( self.balance_between(start_date, end_date) ) { |sum, child| sum += child.balance_between(start_date, end_date) }
  end

  def calculate_previous(item)
    return nil unless head_transaction_item

    result = transaction_items_backward.
      lazy.
      reject{|i| i.id == item.id}.
      select{|i| i.transaction_date <= item.transaction_date}.
      first
  end
  
  def children_cost
    children.reduce(0) { |sum, child| sum + child.cost }
  end

  def children_value
    children.reduce(0) { |sum, child| sum + child.value }
  end

  def cost_as_of(date, force_reload = false)
    return balance_as_of(date, force_reload) unless commodity?
    lots(force_reload).reduce(0){|sum, lot| sum + lot.cost_as_of(date)}
  end

  def cost_with_children_as_of(date, force_reload = false)
    return children(force_reload).reduce(cost_as_of(date, force_reload)) { |sum, child| sum + child.cost_with_children_as_of(date, force_reload) }
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

  def gains_as_of(date, force_reload = false)
    value_as_of(date, force_reload) - cost_as_of(date, force_reload)
  end

  def gains_with_children_as_of(date, force_reload = false)
    children(force_reload).reduce(gains_as_of(date, force_reload)) { |sum, child| sum + child.gains_with_children_as_of(date, force_reload) }
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

  # Inserts the transaction into the transaction linked list chain
  #
  # This action also triggers a recalculation of the item balances
  # and ultimatley a the balances of the account and its parents
  def put_transaction_item(item)
    raise "The item #{item} cannot be inserted into the account #{name}" unless item.account_id == id

    previous = calculate_previous(item)
    if previous
      # Item belongs somewhere after the beginning of the chain

      previous.append_transaction_item(item)
    elsif first_transaction_item_id && (first_transaction_item_id != item.id)
      # This item occurs before all existing items

      replace_first(item)

      # The initial balance calculation for the item isn't triggered becase
      # we never update previous_transaction_item_id
      item.recalculate_balance!
    else
      # This is the very first item for the account
      # All calculations can be done right here

      self.first_transaction_item_id = item.id
      update_head_transaction_item(item)
    end
  end

  def rebuild_transaction_item_links
    self.head_transaction_item_id = nil
    self.first_transaction_item_id = nil
    last = nil
    transaction_items.
      sort{|i| i.transaction.transaction_date}.
      each do |item|
        self.first_transaction_item_id = item.id if self.first_transaction_item_id.nil?
        if last.present?
          item.previous_transaction_item_id = last.id
          last.next_transaction_item_id = item.id
          last.save!
        end
        item.balance = item.polarized_amount + (last.present? ? last.balance : 0)
        item.save!
        last = item
    end
    if last.present?
      update_attributes!(head_transaction_item_id: last.id,
                         balance: last.balance)
    end
  end

  def remove_transaction_item(item)
    if item.previous_transaction_item
      item.previous_transaction_item.update_attribute(:next_transaction_item_id, item.next_transaction_item_id)
    else
      # This is the first transaction item
      update_attribute(:first_transaction_item_id, item.next_transaction_item_id)
    end

    if item.next_transaction_item
      item.next_transaction_item.update_attribute(:previous_transaction_item_id, item.previous_transaction_item_id)
    else
      # This is the head transaction item
      self.head_transaction_item_id = item.previous_transaction_item_id
      recalculate_balances
      save!
    end
  end

  # replaces the first transaction item with the specified item,
  # appending the current first to the item
  def replace_first(item)
    old_first = first_transaction_item
    update_attributes!(first_transaction_item_id: item.id)
    item.append_transaction_item(old_first)
  end

  def recalculate_balances(opts = {})
    with_children_only = opts.fetch(:with_children_only, false)
    force_reload = opts.fetch(:force_reload, false)
    recalculation_fields(opts).each do |field|
      recalculate_field(field, force_reload) unless with_children_only
      recalculate_field("#{field}_with_children", force_reload)
    end
    parent.recalculate_balances!(opts.merge(with_children_only: true)) if parent
  end

  def recalculate_balances!(opts = {})
    recalculate_balances(opts)
    save!
  end

  def root?
    self.parent_id.nil?
  end

  def shares(force_reload = false)
    shares_as_of(Time.now.utc, force_reload)
  end

  def shares_as_of(date, force_reload = false)
    date = ensure_date(date)
    lots(force_reload).
      select{|l| l.purchase_date <= date}.
      reduce(0){|sum, lot| sum + lot.shares_as_of(date)}
  end

  def transaction_items_backward(force_reload = false)
    item = head_transaction_item(force_reload)
    Enumerator.new do |y|
      while item
        y.yield item
        item = item.previous_transaction_item
      end
    end
  end

  def update_head_transaction_item(item)
    self.balance = item.balance
    self.head_transaction_item_id = item.id
    recalculate_balances
    save!
  end

  # Value is the current value of the account. For cash accounts
  # this will always be the same as the balance. For commodity
  # accounts, this will be the sum of the values of the lots
  def value_as_of(date, force_reload = false)
    date = ensure_date(date)
    return balance_as_of(date) unless commodity?
    price = nearest_price(date)
    shrs = shares_as_of(date, force_reload)
    price && shrs ? shrs * price : 0
  end

  def value_with_children_as_of(date, force_reload = false)
    date = ensure_date(date)
    children.reduce(value_as_of(date, force_reload)){|sum, child| sum + child.value_with_children_as_of(date, force_reload)}
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

    def recalculate_field(field, force_reload = false)
      # Assume that most of the time the balance 
      # will not need to be updated
      method = "#{field}_as_of".to_sym
      current = send(method, END_OF_TIME, force_reload)
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
        update_local_balance("#{field}_with_children", delta)
      end
      parent.recalculate_balances(with_children_only: true) if parent
      balance
    end
end
