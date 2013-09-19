# == Schema Information
#
# Table name: transactions
#
#  id               :integer          not null, primary key
#  transaction_date :date             not null
#  description      :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Transaction < ActiveRecord::Base
  has_many :items, class_name: 'TransactionItem', inverse_of: :transaction  
  accepts_nested_attributes_for :items, allow_destroy: true
  attr_accessible :description, :transaction_date, :items_attributes
  belongs_to :user
    
  validates_presence_of :description, :transaction_date
  validate :items_are_present, :credits_and_debits_are_in_balance
  
  before_validation :supply_defaults
  
  def total_credits
    items.credits.reduce(0) { |total, item| total += item.amount }
  end
  
  def total_debits
    items.debits.reduce(0) { |total, item| total += item.amount }
  end
  
  private
  
    def credits_and_debits_are_in_balance
      errors.add(:total_credits, 'must equal total_debits') unless total_credits == total_debits
    end

    def items_are_present
      errors.add(:items, 'cannot be empty') unless items.any?
    end
    
    def supply_defaults
      self.transaction_date ||= Date.today
    end
end
