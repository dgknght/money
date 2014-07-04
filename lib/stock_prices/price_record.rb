module StockPrices
  # Contains price information for a commodity
  class PriceRecord
    attr_accessor :symbol, :date, :price

    def initialize(symbol, date, price)
      self.symbol = symbol
      self.date = date
      self.price = price
    end
  end
end
