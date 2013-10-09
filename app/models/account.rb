# == Schema Information
#
# Table name: accounts
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  account_type :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  balance      :decimal(, )      default(0.0), not null
#  entity_id    :integer          not null
#  parent_id    :integer
#

class Account < ActiveRecord::Base
  belongs_to :entity
  belongs_to :parent, class_name: 'Account', inverse_of: :children
  has_many :children, -> { order :name }, class_name: 'Account', inverse_of: :parent, foreign_key: 'parent_id'

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
  
  validates :account_type, presence: true, 
                           inclusion: { in: ACCOUNT_TYPES }
  validate :parent_must_have_same_type
  
  scope :root, -> { where(parent_id: nil).order(:name) }
  scope :asset, -> { root.where(account_type: Account.asset_type) }
  scope :liability, -> { root.where(account_type: Account.liability_type) }
  scope :equity, -> { root.where(account_type: Account.equity_type) }
  scope :income, -> { root.where(account_type: Account.income_type) }
  scope :expense, -> { root.where(account_type: Account.expense_type) }
  
  def balance_as_of(date)
    balance_between nil, date
  end
  
  def balance_between(start_date, end_date)
    start_date = ensure_date(start_date)
    end_date = ensure_date(end_date)
    
    sum_of_credits = sum_of credit_transaction_items(from: start_date, to: end_date)
    sum_of_debits = sum_of debit_transaction_items(from: start_date, to: end_date)
    
    if LEFT_SIDE.include?(account_type)
      sum_of_debits - sum_of_credits
    else
      sum_of_credits - sum_of_debits
    end
  end
  
  def balance_with_children
    balance + children.sum(:balance)
  end
  
  def balance_with_children_as_of(date)
    children.reduce( self.balance_as_of(date) ) { |sum, child| sum += child.balance_as_of(date) }
  end
  
  def balance_with_children_between(start_date, end_date)
    children.reduce( self.balance_between(start_date, end_date) ) { |sum, child| sum += child.balance_between(start_date, end_date) }
  end
  
  # Adjusts the balance of the account by the specified amount
  def credit(amount)
    amount = 0 - amount if LEFT_SIDE.include?(account_type)
    self.balance += amount
  end
  
  def credit!(amount)
    credit(amount)
    save!
  end
  
  # Adjusts the balance of the account by the specified amount
  def debit(amount)
    amount = 0 - amount if RIGHT_SIDE.include?(account_type)
    self.balance += amount
  end
  
  def debit!(amount)
    debit(amount)
    save!
  end
  
  # returns the number of parents in the parent-child chain
  def depth
    parent ? parent.depth + 1 : 0
  end
  
  def parent_name
    parent ? parent.name : nil
  end

  def path
    parent ? "#{parent.path}/#{name}" : name
  end
  
  private
    def credit_transaction_items(options)
      transaction_items TransactionItem.credit, options
    end
    
    def debit_transaction_items(options)
      transaction_items TransactionItem.debit, options
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
    
    def sum_of(items)
      items.reduce(0) { |sum, item| sum += item.amount }
    end
    
    def transaction_items(action, options)
      start_date = options[:from] || Date.civil(1900, 1, 1) #TODO Someday this should be set to a period closing date to reduce the cost of the search
      end_date = options[:to] || Date.civil(3999, 12, 31)
      
      entity.transactions.includes(:items).where('transaction_date >= ? and transaction_date <= ?', start_date, end_date).map do |transaction|
        transaction.items.where(account_id: id, action: action)
      end.flatten
    end
end
