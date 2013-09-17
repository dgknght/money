class TransactionItem < ActiveRecord::Base
  attr_accessible :account_id, :action, :amount, :transaction_id, :account, :transaction

  ACTIONS = [:credit, :debit]
  
  validates_presence_of :account_id, :action, :amount, :transaction_id
  validates :action, inclusion: { in: ACTIONS }
  
  belongs_to :account
  belongs_to :transaction
  
  scope :credits, -> { where(action: :credit) }
  scope :debits, -> { where(action: :debit) }
end
