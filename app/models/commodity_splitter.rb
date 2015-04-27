# Executes stock splits on a commodity
class CommoditySplitter
  include ActiveModel::Validations

  attr_accessor :numerator, :denominator, :commodity

  validates :numerator, presence: true,
                        numericality: true
  validates :denominator, numericality: true
  validates :commodity, presence: true

  def initialize(options = {})
    options = {denominator: 1}.merge(options).with_indifferent_access
    @numerator = options[:numerator]
    @denominator = options[:denominator]
    @commodity = options[:commodity]
  end

  def split
    return false unless valid?

    ratio = numerator.to_i / denominator.to_i
    commodity.transaction do
      commodity.lots.each do |lot|
        lot.shares_owned = lot.shares_owned * ratio
        lot.price = lot.price / ratio
        lot.save!
      end
      commodity.prices.each do |price|
        price.price = price.price / ratio
        price.save!
      end
    end
  end
end
