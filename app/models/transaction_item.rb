# == Schema Information
#
# Table name: transaction_items
#
#  id             :integer          not null, primary key
#  transaction_id :integer          not null
#  account_id     :integer          not null
#  action         :string(255)      not null
#  amount         :decimal(, )      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TransactionItem < ActiveRecord::Base
  attr_accessible :account_id, :action, :amount, :transaction_id, :account, :transaction

  after_create :update_account_balance
  
  ACTIONS = %w(debit credit)
  class << self
    ACTIONS.each do |action|
      define_method action do
        action
      end
    end
  end
  
  validates_presence_of :account_id, :action, :amount, :transaction
  validates :action, inclusion: { in: ACTIONS }
  
  belongs_to :account
  belongs_to :transaction
  
  scope :credits, -> { where(action: :credit) }
  scope :debits, -> { where(action: :debit) }
  
  private
    def update_account_balance
      method_name = "#{action}!"
      account.send(method_name, amount)
    end
end
