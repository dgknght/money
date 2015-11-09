require 'spec_helper'

describe StockPrices::MemoryDownloadAgent do
  describe '::put' do
    after(:each) do
      StockPrices::MemoryDownloadAgent.reset
    end

    it 'puts the price data in memory for later access' do
      symbol = 'KSS'
      date = '2014-07-04'
      price = 12.34
      StockPrices::MemoryDownloadAgent.put(symbol, date, price)
      agent = StockPrices::MemoryDownloadAgent.new
      records = agent.download_prices(symbol)
      expect(records.length).to eq(1)
      record = records.first
      expect(record.symbol).to eq(symbol)
      expect(record.date).to eq(date)
      expect(record.price).to eq(price)
    end
  end
end
