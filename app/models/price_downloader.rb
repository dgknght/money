# Uses a configurable service client to download
# prices from an external source
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

  def create_agent
    MemoryDownloadAgent.new
  end

  def process_commodity(commodity)
    agent.download_prices(commodity.symbol).each do |price_record|
      commodity.prices.create!(trade_date: price_record.date, price: price_record.price)
    end
  end
end
