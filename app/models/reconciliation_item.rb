# == Schema Information
#
# Table name: reconciliation_items
#
#  id                  :integer          not null, primary key
#  reconciliation_id   :integer          not null
#  transaction_item_id :integer          not null
#  created_at          :datetime
#  updated_at          :datetime
#

class ReconciliationItem < ActiveRecord::Base
  belongs_to :reconciliation, inverse_of: :items
  belongs_to :transaction_item
  
  validates_presence_of :reconciliation, :transaction_item_id
  validate :transaction_item_belongs_to_account
  
  private
    def accounts_match
      return false unless reconciliation
      return false unless reconciliation.account
      return false unless transaction_item
      return false unless transaction_item.account
      reconciliation.account.id == transaction_item.account.id
    end
    
    def transaction_item_belongs_to_account
      errors.add(:transaction_item, "must belong to the account being reconciled") unless accounts_match
    end
end
