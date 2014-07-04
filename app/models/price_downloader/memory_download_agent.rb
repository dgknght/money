# Download agent implementation that works
# with in-memory data for testing purposes
class PriceDownloader
  class MemoryDownloadAgent

    PriceRecord = Struct.new(:symbol, :date, :price)

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
      prices[symbol] << PriceRecord.new(symbol, date, price)
    end
  end
end
