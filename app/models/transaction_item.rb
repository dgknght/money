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

  before_create :calculate_balance
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

  after_update :recalculate_balance!, if: :should_recalculate_balance?
  after_update :move_accounts, if: :account_id_changed?

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
  validate :previous_is_not_self, :next_is_not_self
  
  belongs_to :account, inverse_of: :transaction_items
  belongs_to :transaction, inverse_of: :items
  has_one :reconciliation_item
  belongs_to :previous_transaction_item, class_name: 'TransactionItem'
  belongs_to :next_transaction_item, class_name: 'TransactionItem'
  
  scope :credits, -> { where(action: TransactionItem.credit) }
  scope :debits, -> { where(action: TransactionItem.debit) }
  
  scope :reconciled, -> { where(reconciled: true) }
  scope :unreconciled, -> { where(reconciled: false) }
  
  delegate :entity, :transaction_date, to: :transaction, allow_nil: true

  # Places the specified item after this instance in the chain, 
  # attaching the next item after the new item, if it exists. Also
  # update the balance of the specified item and all items down the chain
  def append_transaction_item(item)
    raise "The item must be saved" unless item.id
    raise "Cannot append a transaction item onto itself (item#{item}, self=#{to_s})" if item.id == id
    raise "The item must be from the same account" unless item.account_id == account_id

    item.update_attributes(previous_transaction_item_id: id, # This will cause the balance to be recalculated down the chain
                           next_transaction_item_id: next_transaction_item_id)
    if next_transaction_item_id
      next_transaction_item.previous_transaction_item = item
      next_transaction_item.save!
    end

    update_attribute(:next_transaction_item_id, item.id)
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
        account.update_head_transaction_item(self)
      end
    end
  end
  
  def reconciled?
    reconciled
  end

  def to_s
    "#<TransactionItem: id=#{id} #{action} #{account.try(:name)} #{amount.to_f} on #{transaction_date} #{previous_transaction_item_id} <- -> #{next_transaction_item_id}>"
  end

  private
    def calculate_balance
      self.balance = previous_balance + amount
    end

    def ensure_not_reconciled
      if reconciled?
        raise Money::CannotDeleteError, "The transaction item has already been reconciled. Undo the reconciliation, then delete the item."
      end
    end

    def move_accounts
      return unless account_id_was

      old_account = Account.find(account_id_was)
      old_account.remove_transaction_item(self)
      account.put_transaction_item(self)
    end

    def next_is_not_self
      if id && next_transaction_item_id == id
        errors.add(:next_transaction_item_id, 'cannot be the same as self')
      end
    end
    
    def polarity
      account.polarity(action)
    end

    def previous_balance
      previous_transaction_item.try(:balance) || 0
    end

    def previous_is_not_self
      if id && previous_transaction_item_id == id
        errors.add(:previous_transaction_item_id, 'cannot be the same as self')
      end
    end
    
    def insert_into_account
      account.put_transaction_item(self)
    end

    def remove_from_chain
      account.remove_transaction_item(self)
    end

    def should_recalculate_balance?
      previous_transaction_item_id_changed? || amount_changed?
    end
end
