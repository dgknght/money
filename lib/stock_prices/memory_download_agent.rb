
# Dowwnload agent implementation that works
# with in-memory data for testing purposes
module StockPrices
  class MemoryDownloadAgent

    def download_prices(symbol)
      prices[symbol]
    end

    def self.prices
      @@prices ||= Hash.new { |h, k| h[k] = [] }
    end

    def prices
      MemoryDownloadAgent.prices
    end

    def self.put(symbol, date, price)
      prices[symbol] << StockPrices::PriceRecord.new(symbol, date, price)
    end

    def self.reset
      @@prices = nil
    end
  end
end
