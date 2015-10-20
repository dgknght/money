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
  belongs_to :commodity, inverse_of: :prices

  after_create :update_account
  after_update :update_account

  validates_presence_of :commodity_id, :trade_date
  validates_uniqueness_of :trade_date, scope: :commodity_id
  validates :price, presence: true, numericality: { greater_than: 0, less_than: 10_000 }

  default_scope { order('trade_date DESC') }

  def self.put_price(commodity, trade_date, price)
    raise 'commodity must be specified' unless commodity
    raise 'commodity must have a prices method' unless commodity.respond_to?(:prices)
    price_model = commodity.prices.find_by_trade_date(trade_date)
    if price_model
      price_model.update_attribute(:price, price)
    else
      price_model = commodity.prices.create!(trade_date: trade_date, price: price)
    end
    price_model
  end

  private

  def all_accounts
    commodity.lots.active.map(&:account).uniq{|a| a.id}
  end

  def update_account
    all_accounts.each{|a| a.recalculate_balances!(only: [:value, :cost, :gains])}
  end
end
