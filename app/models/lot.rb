# == Schema Information
#
# Table name: lots
#
#  id            :integer          not null, primary key
#  account_id    :integer          not null
#  commodity_id  :integer          not null
#  price         :decimal(8, 4)    not null
#  shares_owned  :decimal(8, 4)    not null
#  purchase_date :date             not null
#  created_at    :datetime
#  updated_at    :datetime
#

class Lot < ActiveRecord::Base
  validates_presence_of :account_id, :price, :commodity_id, :shares_owned, :purchase_date
  validates_numericality_of :price, greater_than: 0
end
