# Aggregates and summarizes lots by commodity
class HoldingCollection
  include Enumerable

  def <<(lot)
    lots << lot
    @aggregation = nil
  end

  def +(new_lots)
    new_lots.each { |l| self << l }
    self
  end

  def each
    aggregation.each { |h| yield h }
  end

  def initialize(lot_or_lots = [])
    @lots = [*lot_or_lots]
  end

  def total_cost
    sum :total_cost
  end

  def total_current_value
    sum :current_value
  end

  def total_gain_loss
    sum :total_gain_loss
  end

  private

  def aggregate
    hash = {}
    lots.each do |lot|
      holding = hash[lot.commodity.symbol]
      unless holding
        holding = Holding.new
        hash[lot.commodity.symbol] = holding
      end
      holding << lot
    end
    hash.values
  end

  def aggregation
    @aggregation ||= aggregate
  end

  def lots
    @lots ||= []
  end

  def sum(method_name)
    aggregation.reduce(0) { |sum, holding| sum + holding.send(method_name) }
  end
end
