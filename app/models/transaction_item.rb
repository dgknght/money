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
  before_create :update_balance
  after_create :insert_into_the_chain

  # when updating we need to:
  #   if our position in the chain should change
  #     remove the item from the chain
  #     insert the item back into the chain at the correct location
  #   otherwise if the balance has changed
  #     either
  #       update the next item in the chain
  #     or
  #       update the account 
#  before_update :update_balance # determine insert point, update next and previous if necessary
#  after_update :update_chain # remove from chain

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
  
  def polarized_amount
    amount * polarity
  end
  
  def reconciled?
    reconciled
  end

  def update_balance
    self.balance = previous_balance + polarized_amount

    puts "#{action} #{account.name} #{amount} update_balance #{balance}"

    balance
  end

  def update_balance!
    update_balance
    save!
  end
  
  private
    def add_to_new_chain
      puts "Add to the new chain #{account.name}"
    end

    def ensure_not_reconciled
      if reconciled?
        raise Money::CannotDeleteError, "The transaction item has already been reconciled. Undo the reconciliation, then delete the item."
      end
    end
    
    def polarity
      account.polarity(action)
    end
    
    def previous_balance
      previous.try(:balance) || BigDecimal.new(0)
    end

    def rollback_account_balance
      method_name = "#{action}!"
      previous_account = Account.where(id: account_id_was).first
      previous_account.send(method_name, amount_was * -1) if previous_account
    end
    
    def remove_from_chain

      a = account_id_was.present? && account_id_was != account_id ? Account.find(account_id_was) : account

      puts "remove from account #{a.name}"

      if self.next.present?
        # This is not the last transaction, attach the next to the previous
        previous.update_attribute(:next_id, next_id) if previous
      else
        # This is the last transaction, update the account head
        a.update_attribute(:head_id, next_id)
      end

      if previous.present?
        # This is not the first transaction, attache the previous to the next
        self.next.update_attribute(:previous_id, previous_id) if self.next
      else
        # This is the first transaction, update the account first
        a.update_attribute(:first_id, next_id)
      end
    end

    def calculated_previous
      @calculated_previous ||= calculate_previous
    end

    def calculate_previous
      # This should only be called if this is not the only item in the account
      result = account.head_transaction_item
      while result && result.transaction.transaction_date > transaction.transaction_date
        result = result.previous_transaction_item
      end
    end

    def update_balance
      if calculated_previous
        self.balance = polarized_amount + calculated_previous
        self.previous_transaction_item_id = calculated_previous.id
        self.next_transaction_item_id = calculated_previous.next_transaction_item_id
      else
        self.balance = polarized_amount
      end
    end

    def insert_into_the_chain
      if account.head_transaction_item.nil?
        # This is the only transaction
        account.update_attributes!(first_transaction_item_id: id,
                                   head_transaction_item_id: id,
                                   balance: balance)
      else
        if calculated_previous.present?
          # This is not the first
          unless calculated_previous.next_transaction_item_id.present?
            account.update_attribute(:balance, balance)
          end
          calculated_previous.update_attributes!(next_transaction_item_id: id)
        else
          # This is the first, but not the only
          account.update_attribute(:first_transaction_item_id, id)
        end
        next_transaction_item.try(:update_balance!)
      end
    end
end
