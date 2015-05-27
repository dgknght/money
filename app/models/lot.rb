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
  belongs_to :account, inverse_of: :lots
  belongs_to :commodity, inverse_of: :lots
  has_many :transactions, class_name: 'LotTransaction', dependent: :destroy

  validates_presence_of :account_id, :price, :commodity_id, :shares_owned, :purchase_date
  validates_numericality_of :price, greater_than: 0

  scope :active, -> { where('shares_owned > 0') }
  scope :fifo, -> { order(purchase_date: :asc) }
  scope :filo, -> { order(purchase_date: :desc) }

  def cost
    (price || 0) * (shares_owned || 0)
  end

  def cost_as_of(date)
    return 0 unless transactions.present?

    shares_as_of(date) * price
  end

  def current_value(as_of = Date.today)
    return 0 if shares_owned == 0
    (most_recent_price(as_of) || price) * shares_owned
  end

  def gains
    current_value - cost
  end

  private

  def most_recent_price(as_of)
    commodity.prices.
      where(['trade_date <= ?', as_of]).
      order(trade_date: :desc).
      first.try(:price)
  end

  def shares_as_of(date)
    date = Chronic.parse(date) if date.is_a? String
    transactions.
      select{|t| t.transaction && t.transaction.transaction_date <= date}.
      reduce(0){|sum, t| sum + t.shares_traded}
  end
end
