StockPrices.configure do |config|
  config.download_agent = case
                            when Rails.env.development?
                              StockPrices::DreamDownloadAgent
                            when Rails.env.test?
                              StockPrices::MemoryDownloadAgent
                            when Rails.env.production?
                              StockPrices::QuandlDownloadAgent
                            end
end
