require 'spec_helper'

describe StockPrices::PriceDownloader do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:kss) { FactoryGirl.create(:commodity, symbol: 'KSS', name: 'Knight Software Services', entity: entity) }

  it 'should be creatable from an entity' do
    downloader = StockPrices::PriceDownloader.new(entity)
    expect(downloader).not_to be_nil
  end

  after(:each) { StockPrices.reset }

  describe '#download' do
    before(:each) do
      StockPrices::MemoryDownloadAgent.put('KSS', '2014-01-01', 12.34)
    end
    after(:each) do
      StockPrices::MemoryDownloadAgent.reset
    end

    it 'should query the configured service client to get prices for existing entities' do
      expect do
        StockPrices::PriceDownloader.new(entity).download
      end.to change(Price, :count).by(1)
    end

    it 'should use the configured agent' do
      class TestDownloadAgent
        def download_prices(symbol)
          [StockPrices::PriceRecord.new(symbol, Date.today, 99.99)]
        end
      end

      StockPrices.configure do |config|
        config.download_agent = TestDownloadAgent
      end

      downloader = StockPrices::PriceDownloader.new(entity)
      downloader.download
      expect(kss.prices.last.price).to eq(99.99)
    end
  end
end
