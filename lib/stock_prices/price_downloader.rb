# Uses a configurable service client to download
# prices from an external source
module StockPrices
  class PriceDownloader
    def initialize(entity)
      railse 'Entity must have a commodities collection' unless entity.respond_to?(:commodities)
      @entity = entity
    end

    def download
      @entity.commodities.each { |c| process_commodity(c) }
    end

    private

    def agent
      @agent ||= create_agent
    end

    def agent_class
      StockPrices.configuration.download_agent || MemoryDownloadAgent
    end

    def create_agent
      agent_class.new
    end

    def process_commodity(commodity)
      agent.download_prices(commodity.symbol).each do |p|
        Price.put_price(commodity, p.date, p.price)
      end
    end
  end
end
