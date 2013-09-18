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
  attr_accessible :description, :transaction_date
  
  validates_presence_of :description, :transaction_date
  validate :credits_and_debits_are_in_balance
  
  before_validation :supply_defaults
  
  has_many :items, class_name: 'TransactionItem'
  belongs_to :user
  
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

    def supply_defaults
      self.transaction_date ||= Date.today
    end
end
