# == Schema Information
#
# Table name: prices
#
#  id           :integer          not null, primary key
#  commodity_id :integer          not null
#  trade_date   :date             not null
#  price        :decimal(8, 4)    not null
#  created_at   :datetime
#  updated_at   :datetime
#

class Price < ActiveRecord::Base
  belongs_to :commodity

  validates_presence_of :commodity_id, :trade_date
  validates :price, presence: true, numericality: { greater_than: 0 }
end
