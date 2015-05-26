# == Schema Information
#
# Table name: transaction_items
#
#  id             :integer          not null, primary key
#  transaction_id :integer          not null
#  account_id     :integer          not null
#  action         :string(255)      not null
#  amount         :decimal(, )      not null
#  created_at     :datetime
#  updated_at     :datetime
#  reconciled     :boolean          default(FALSE), not null
#  memo           :string(100)
#  confirmation   :string(50)
#

class TransactionItem < ActiveRecord::Base
  after_create :update_account_balance
  after_update :rollback_account_balance, :update_account_balance
  before_destroy :ensure_not_reconciled
  after_destroy :rollback_account_balance
  
  ACTIONS = %w(debit credit)
  class << self
    ACTIONS.each do |action|
      define_method action do
        action
      end
    end
  end

  def self.opposite_action(action)
    return nil unless ACTIONS.include?(action)
    action == TransactionItem.debit ? TransactionItem.credit : TransactionItem.debit
  end
  
  validates_presence_of :account_id, :action, :amount, :transaction
  validates :action, inclusion: { in: ACTIONS }
  
  belongs_to :account, inverse_of: :transaction_items
  belongs_to :transaction, inverse_of: :items
  has_one :reconciliation_item
  
  scope :credits, -> { where(action: TransactionItem.credit) }
  scope :debits, -> { where(action: TransactionItem.debit) }
  
  scope :reconciled, -> { where(reconciled: true) }
  scope :unreconciled, -> { where(reconciled: false) }
  
  def polarized_amount
    amount * polarity
  end
  
  def reconciled?
    reconciled
  end
  
  private
    def ensure_not_reconciled
      if reconciled?
        raise Money::CannotDeleteError, "The transaction item has already been reconciled. Undo the reconciliation, then delete the item."
      end
    end
    
    def polarity
      account.polarity(action)
    end
    
    def rollback_account_balance
      method_name = "#{action}!"
      previous_account = Account.where(id: account_id_was).first
      previous_account.send(method_name, amount_was * -1) if previous_account
    end
    
    def update_account_balance
      method_name = "#{action}!"
      account.reload
      account.send(method_name, amount)
    end
end
