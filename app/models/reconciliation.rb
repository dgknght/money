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
  default_scope { order(:reconciliation_date) }
  
  def balance_difference
    (closing_balance || 0) - reconciled_balance
  end
  
  def previous_balance
    previous = account.reconciliations.where('reconciliation_date < ?', reconciliation_date).last
    previous.nil? ? 0 : previous.closing_balance
  end
  
  def reconciled_balance
    return 0 unless account
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
    def selected?(transaction_item)
      items.select { |i| i.transaction_item_id == transaction_item.id }.any?
    end
end
