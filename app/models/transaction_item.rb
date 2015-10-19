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
#  balance        :decimal(, )      default(0.0), not null
#  index          :integer          default(0), not null
#

class TransactionItem < ActiveRecord::Base
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

  scope :occurring_before, -> (date) { joins(:transaction).where('transactions.transaction_date < ?', date).order('transaction_items."index"').reverse_order }
  scope :occurring_between, -> (start_date, end_date) { joins(:transaction).where('? < transactions.transaction_date and transactions.transaction_date < ?', start_date, end_date).order('transaction_items."index"').reverse_order }
  scope :occurring_on_or_after, -> (date) { joins(:transaction).where('transactions.transaction_date >= ?', date).order('transactions.transaction_date', 'transaction_items."index"') }
  
  delegate :entity, :transaction_date, to: :transaction, allow_nil: true

  def polarized_amount
    amount * polarity
  end

  def reconciled?
    reconciled
  end

  def to_s
    "#<TransactionItem: id=#{id} index=#{index}: #{action} #{account.try(:name)} #{amount.to_f} (#{balance.to_f}) on #{transaction_date}>"
  end

  private
    def account_present?
      return account.present?
    end

    def after_items(target_account = nil)
      ids = (target_account || account).
        transaction_items.
        occurring_on_or_after(transaction.transaction_date).
        map(&:id).
        reject{|id| id == self.id}
      TransactionItem.find(ids)
    end

    def calculate_balance
      self.balance = previous_balance + amount
    end

    def ensure_not_reconciled
      if reconciled?
        raise Money::CannotDeleteError, "The transaction item has already been reconciled. Undo the reconciliation, then delete the item."
      end
    end

    def lookup_previous_transaction_item
      account.transaction_items.occurring_before(transaction.transaction_date).first
    end

    def move_accounts
      return unless account_id_was

      old_account = Account.find(account_id_was)
      process_removal(old_account)
    end

    def polarity
      account.polarity(action)
    end

    def previous_balance
      previous_transaction_item.try(:balance) || 0
    end

    def previous_index
      previous_transaction_item.try(:index) || -1
    end

    def previous_transaction_item
      @previous_transaction_item ||= lookup_previous_transaction_item
    end

    def process_after_items(starting_balance, starting_index, target_account = nil)
      last_balance = starting_balance
      last_index = starting_index

      after_items(target_account).each do |item|
        last_index   = item.index   = last_index + 1
        last_balance = item.balance = last_balance + item.polarized_amount
        item.save! if item.changed?
      end
      [last_balance, last_index]
    end

    def process_insertion
      self.balance = previous_balance + polarized_amount
      self.index = previous_index + 1

      last_balance, _ = process_after_items(balance, index)
      account.balance = last_balance
      account.save!
    end

    def process_removal(target_account = nil)
      target_account ||= self.account

      last_balance, _ = process_after_items(previous_balance, previous_index, target_account)
      target_account.balance = last_balance
      target_account.save!
    end

    def process_update
      process_removal(Account.find(account_id_was)) if account_id_changed?
      process_insertion
    end
end
