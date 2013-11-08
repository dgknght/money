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
  has_many :items, class_name: 'ReconciliationItem', autosave: true
  
  validates_presence_of :account_id, :reconciliation_date, :closing_balance
  
  default_scope { order(:reconciliation_date) }
  
  def previous_balance
    previous = account.reconciliations.where('reconciliation_date < ?', reconciliation_date).last
    previous.nil? ? 0 : previous.closing_balance
  end
  
  def reconciled_balance
    account.transaction_items.unreconciled.select do |item|
      selected?(item)
    end.reduce(previous_balance) do |sum, item|
      sum += item.polarized_amount
    end
  end
  
  private
    def selected?(transaction_item)
      items.select { |i| i.transaction_item_id == transaction_item.id }.any?
    end
end
