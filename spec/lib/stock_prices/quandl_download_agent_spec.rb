require 'spec_helper'

describe StockPrices::QuandlDownloadAgent do
  describe '#download_prices' do
    it 'returns prices from the web service' do
      # don't really want to connect to an external service for my unit tests
#      agent = StockPrices::QuandlDownloadAgent.new
#      prices = agent.download_prices('AAPL')
#      expect(prices).not_to be_nil
    end
  end
end
