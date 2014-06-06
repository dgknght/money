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
  belongs_to :account
  belongs_to :commodity
  has_many :transactions, class_name: 'LotTransaction'

  validates_presence_of :account_id, :price, :commodity_id, :shares_owned, :purchase_date
  validates_numericality_of :price, greater_than: 0

  default_scope { where('shares_owned > 0') }
  scope :fifo, -> { order(purchase_date: :asc) }
  scope :filo, -> { order(purchase_date: :desc) }

  def cost
    (price || 0) * (shares_owned || 0)
  end

  def current_value(as_of = Date.today)
    return 0 if shares_owned == 0
    (most_recent_price(as_of) || price) * shares_owned
  end

  def gain_loss
    current_value - cost
  end

  private

  def most_recent_price(as_of)
    commodity.prices.
      where(['trade_date <= ?', as_of]).
      order(trade_date: :desc).
      first.try(:price)
  end
end
