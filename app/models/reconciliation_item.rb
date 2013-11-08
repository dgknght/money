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
  belongs_to :reconciliation
  belongs_to :transaction_item
  
  validates_presence_of :reconciliation_id, :transaction_item_id
end
