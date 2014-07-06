# == Schema Information
#
# Table name: transactions
#
#  id               :integer          not null, primary key
#  transaction_date :date             not null
#  description      :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  entity_id        :integer          not null
#

class Transaction < ActiveRecord::Base
  has_many :items, class_name: 'TransactionItem', inverse_of: :transaction, dependent: :destroy
  has_many :attachments, inverse_of: :transaction, dependent: :destroy
  has_many :lot_transactions
  accepts_nested_attributes_for :items, allow_destroy: true
  belongs_to :entity
    
  validates_presence_of :description, :transaction_date, :entity_id
  validate :items_are_present, :credits_and_debits_are_in_balance
  before_validation :supply_defaults
  
  default_scope { order(transaction_date: :desc) }
  
  def as_json(options)
    super(options.merge( include: :items ))
  end
  
  def total_credits
    sum_items(TransactionItem.credit)
  end
  
  def total_debits
    sum_items(TransactionItem.debit)
  end
  
  private
  
    def credits_and_debits_are_in_balance
      c = total_credits
      d = total_debits
      errors.add(:total_credits, "must equal total_debits (#{c} != #{d})") unless c == d 
    end

    def items_are_present
      errors.add(:items, 'cannot be empty') unless items.any?
    end
    
    def sum_items(action)
      items.select do |item|
        item.action == action && !item.destroyed?
      end.reduce(0) do |total, item|
        total += item.amount
      end
    end
    
    def supply_defaults
      self.transaction_date ||= Date.today
    end
end
