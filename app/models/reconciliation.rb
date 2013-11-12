# == Schema Information
#
# Table name: reconciliations
#
#  id                  :integer          not null, primary key
#  account_id          :integer          not null
#  reconciliation_date :date             not null
#  closing_balance     :decimal(, )      not null
#  created_at          :datetime
#  updated_at          :datetime
#

class Reconciliation < ActiveRecord::Base
  belongs_to :account
  has_many :items, class_name: 'ReconciliationItem', autosave: true, inverse_of: :reconciliation
  accepts_nested_attributes_for :items
  
  validates_presence_of :account_id, :reconciliation_date, :closing_balance
  validates_numericality_of :balance_difference, equal_to: 0
  
  before_validation :ensure_defaults
  
  default_scope { order(:reconciliation_date) }
  
  def balance_difference
    (closing_balance || 0) - reconciled_balance
  end
  
  def previous_balance
    previous_reconciliation.nil? ? 0 : previous_reconciliation.closing_balance
  end
  
  def previous_reconciliation_date
    previous_reconciliation.nil? ? nil : previous_reconciliation.reconciliation_date
  end
  
  def reconciled_balance
    return 0 unless account
    return 0 if account.transaction_items.unreconciled.length == 0
    
    account.transaction_items.unreconciled.select do |item|
      selected?(item)
    end.reduce(previous_balance) do |sum, item|
      sum += item.polarized_amount
    end
  end
  
  def <<(transaction_item)
    items.new(transaction_item: transaction_item)
  end
  
  private
    def calculate_reconciliation_date
      return Date.today unless previous_reconciliation_date
      previous_reconciliation_date >> 1
    end
    
    def ensure_defaults
      self.reconciliation_date ||= calculate_reconciliation_date
    end
    
    def must_be_in_balance
      errors.add(:balance_difference, "must be equal to zero.") unless balance_difference == 0
    end
    
    def previous_reconciliation
      return nil unless account
      return account.reconciliations.last unless reconciliation_date
      @previous_reconciliation ||= account.reconciliations.where('reconciliation_date < ?', reconciliation_date).last
    end
    
    def selected?(transaction_item)
      items.select { |i| i.transaction_item_id == transaction_item.id }.any?
    end
end
