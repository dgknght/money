# == Schema Information
#
# Table name: commodities
#
#  id         :integer          not null, primary key
#  entity_id  :integer
#  name       :string(255)
#  symbol     :string(5)
#  market     :string(10)
#  created_at :datetime
#  updated_at :datetime
#

# Represents something that can be traded on a market
class Commodity < ActiveRecord::Base
  MARKETS = %w(nyse nasdaq)
  class << self
    MARKETS.each do |market|
      define_method market do 
        market
      end
    end
  end

  belongs_to :entity

  validates :name,  presence: true,
                    uniqueness: { scope: :entity_id }
  validates :symbol,  presence: true,
                      uniqueness: { scope: :entity_id },
                      format: { with: /\A[a-z]+\z/i, message: 'cannot contain spaces' }
  validates :market,  presence: true,
                      inclusion: { in: MARKETS }
end
