# Used to aggregate lots by commodity
class Holding
  COMMODITY_MISMATCH_MESSAGE = 'All lots in the holding must belong to the same commodity'
  def <<(lot)
    raise COMMODITY_MISMATCH_MESSAGE unless lots.empty? || lot.commodity == commodity
    @lots << lot
  end

  def +(lots)
    lots.each { |lot| self << lot }
  end

  def average_price
    total_cost / total_shares
  end

  def commodity
    @lots.first.commodity
  end

  def current_value
    @lots.reduce(0) { |sum, lot| sum += lot.current_value }
  end

  def initialize(lot_or_lots = [])
    @lots = [*lot_or_lots]
    validate_only_one_commodity
  end

  def lots
    @lots
  end

  def total_cost
    sum(:cost)
  end

  def total_gain_loss
    sum(:gain_loss)
  end

  def total_shares
    sum(:shares_owned)
  end

  private

  def sum(method_name)
    @lots.reduce(0) { |sum, lot| sum + lot.send(method_name) }
  end

  def validate_only_one_commodity
    commodity = nil
    lots.each do |lot|
      commodity ||= lot.commodity
      raise COMMODITY_MISMATCH_MESSAGE unless lot.commodity == commodity
    end
  end
end
