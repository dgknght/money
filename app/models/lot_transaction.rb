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
  belongs_to :lot, inverse_of: :transactions
  belongs_to :owning_transaction, inverse_of: :lot_transactions, class_name: 'Transaction', foreign_key: :transaction_id
  validates_presence_of :lot_id, :transaction_id, :shares_traded, :price

  delegate :transaction_date, to: :owning_transaction
  def sale?
    shares_traded < 0
  end

  def purchase?
    shares_traded > 0
  end
end
