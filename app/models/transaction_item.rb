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

  # When a new transaction item is created:
  #   1. It is the only item
  #      Set instance.balance = polarized_amount
  #
  #      Set account.head_transaction_item_id = instance.id
  #      Set account.first_trnsaction_item_id = instance.id
  #      Set account.balance = instance.balance
  #
  #   2. It is the last item
  #      Set instance.previous_transaction_item_id = account.head_transaction_item_id
  #      Set instance.balance = polarized_amount + previous_transaction_item.balance
  #
  #      Set account.head_transaction_item_id = instance.id
  #      Set account.balance = instance.balance
  #
  #   3. It is the first item
  #      Set instance.next_transaction_item_id = account.first_transaction_item_id
  #      Set instance.balance = polarized_amount
  #
  #      Set account.first_transaction_item.previous_transaction_item_id = instance.id
  #      Set account.first_transaction_item_id = instance.id
  #      Update balance down the chain
  #
  #   4. It is neither the first nor the last item
  #      Set instance.previous_transaction_item_id = calculated_previous.id
  #      Set instance.next_transaction_item_id = calculated_previous.next_transaction_item_id
  #      Set instance.balance = polarized_amount + calculated_previous.balance
  #
  #      Set calculated_previous.next_transaction_item.previous_transaction_item_id = instance.id
  #      Set calculated_previous.next_transaction_item_id = instance.id
  #      Update balance down the chain

  after_create :insert_into_account

  # When a transaction item is updated
  #
  # 1. The amount changes
  #    Update balance down the chain
  #
  # 2. The account changes
  #    Remove from the original account chain
  #    Insert into the new account change (see creation notes above)
  #
  # 3. The transaction date changes
  #    Remove from the account chain
  #    Insert back into the account chain at the proper location (see creation notes above)

  after_update :recalculate_balance!, if: :previous_transaction_item_id_changed? 

  before_destroy :ensure_not_reconciled
  after_destroy :remove_from_chain
  
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
  has_one :previous_transaction_item, class_name: 'TransactionItem', foreign_key: 'previous_transaction_item_id'
  has_one :next_transaction_item, class_name: 'TransactionItem', foreign_key: 'next_transaction_item_id'
  
  scope :credits, -> { where(action: TransactionItem.credit) }
  scope :debits, -> { where(action: TransactionItem.debit) }
  
  scope :reconciled, -> { where(reconciled: true) }
  scope :unreconciled, -> { where(reconciled: false) }
  
  def append_transaction_item(item)
    item.update_attributes!(previous_transaction_item_id: id,
                            next_transaction_item_id: next_transaction_item_id,
                            balance: item.polarized_amount + balance) # Should the balance update be separate?

    update_attributes!(next_transaction_item_id: item.id)
    if item.next_transaction_item_id
      item.next_transaction_item.update_attribute(previous_transaction_item_id: item.id)
    end
  end

  def polarized_amount
    amount * polarity
  end

  def recalculate_balance!
    new_balance = polarized_amount + previous_balance
    unless new_balance == balance
      update_attribute(:balance, new_balance)
      if next_transaction_item
        next_transaction_item.recalculate_balance!
      else
        account.update_attribute(:balance, balance)
      end
    end
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

    def previous_balance
      previous_transaction_item.try(:balance) || 0
    end
    
    def insert_into_account
      account.put_transaction_item(self)
    end
end
