require 'spec_helper'

describe StockPrices::PriceDownloader do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:ira) { FactoryGirl.create(:commodities_account, entity: entity) }
  let (:ob) { FactoryGirl.create(:equity_account, entity: entity) }
  let!(:kss) { FactoryGirl.create(:commodity, symbol: 'KSS', name: 'Knight Software Services', entity: entity) }
  let!(:t1) { FactoryGirl.create(:transaction, amount: 2_000, debit_account: ira, credit_account: ob) }
  let!(:t2) { CommodityTransactionCreator.new(account: ira, symbol: 'KSS', shares: 100, value: 1_000, action: 'buy').create! }

  it 'is creatable from an entity' do
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

    it 'queries the configured service client to get prices for existing commodities' do
      expect do
        StockPrices::PriceDownloader.new(entity).download
      end.to change(Price, :count).by(1)
    end

    it 'updates the price if a price already exists for a given day' do
      price = kss.prices.create!(trade_date: '2014-01-01', price: 10)
      expect do
        StockPrices::PriceDownloader.new(entity).download
        price.reload
      end.to change(price, :price).from(10).to(12.34)
    end

    it 'uses the configured agent' do
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

      expect(kss.prices.last.price).to eq(BigDecimal.new('99.99'))
    end
  end
end
