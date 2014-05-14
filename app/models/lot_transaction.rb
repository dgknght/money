# == Schema Information
#
# Table name: lot_transactions
#
#  id             :integer          not null, primary key
#  lot_id         :integer          not null
#  transaction_id :integer          not null
#  shares_traded  :decimal(8, 4)    not null
#  price          :decimal(8, 4)    not null
#  created_at     :datetime
#  updated_at     :datetime
#

class LotTransaction < ActiveRecord::Base
  belongs_to :lot
  belongs_to :transaction
  validates_presence_of :lot_id, :transaction_id, :shares_traded, :price
end
