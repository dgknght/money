# Module provides tools for dowloading
# stock prices from the internet
module StockPrices
  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = nil
  end
end

