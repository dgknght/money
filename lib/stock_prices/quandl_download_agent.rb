require 'net/http'

# Download agent implementation that reads prices
# from www.quandl.com
module StockPrices
  BASE_URL = 'http://www.quandl.com/api/v1/datasets/WIKI/'

  # Downloads stock prices using quandl
  class QuandlDownloadAgent
    def download_prices(symbol)
      transformed_data(symbol).map do |hash|
        PriceRecord.new(symbol, hash['Date'], hash['Close'])
      end
    end

    private

    def last_business_date
      date = Date.today
      date = date - 1 if DateTime.now.hour < 3 # need to handle timezones here
      date = date - 1 if date.saturday?
      date = date - 2 if date.sunday?
      date
    end

    def parsed_data(symbol)
      data = raw_data(symbol)
      JSON.parse(data)
    end

    def raw_data(symbol)
      # TODO add ability to specify the dates
      date = last_business_date
      url = "#{BASE_URL}#{symbol}.json?trim_start=#{(date - 3).iso8601}&trim_end=#{date.iso8601}"
      uri = URI.parse(url)
      #TODO Add authentication
      response = Net::HTTP.get_response(uri)
      response.body
    end

    def transform(json)
      columns = json['column_names']
      data = json['data']
      data.map do |row|
        record = {}
        row.each_with_index { |value, index| record[columns[index]] = value }
        record
      end
    end

    def transformed_data(symbol)
      data = parsed_data(symbol)
      hashes = transform(data)
    end
  end
end

# http://www.quandl.com/api/v1/datasets/WIKI/AAPL.json?trim_start=2014-07-01&trim_end=2014-07-04
#
# {
#   "errors":{},
#   "id":9775409,
#   "source_code":"WIKI",
#   "source_name":
#   "Quandl Open Data",
#   "code":"AAPL",
#   "name":"(AAPL) Prices, Dividends, Splits and Trading Volume",
#   "urlize_name":"-AAPL-Prices-Dividends-Splits-and-Trading-Volume",
#   "description":"<p>End of day open, high, low, close and volume, dividends and splits, and split/dividend adjusted open, high, low close and volume for Apple Inc. (AAPL). Ex-Dividend is non-zero on ex-dividend dates. Split Ratio is 1 on non-split dates. Adjusted prices are calculated per CRSP (<a href=\"http://www.crsp.com/products/documentation/crsp-calculations\" rel=\"nofollow\" target=\"blank\">www.crsp.com/products/documentation/crsp-calculations</a>)</p><p></p><p></p><p></p><p></p>\n\n<p></p><p></p><p></p><p></p><p>This data is in the public domain. You may copy, distribute, disseminate or include the data in other products for commercial and/or noncommercial purposes.</p>\n<br><br><br><br><p>This data is part of Quandl's Wiki initiative to get financial data permanently into the public domain. Quandl relies on users like you to flag errors and provide data where data is wrong or missing. Get involved: <a href=\"mailto:connect@quandl.com\" rel=\"nofollow\" target=\"blank\">connect@quandl.com</a>\n\n</p>",
#   "updated_at":"2014-07-04T20:51:46Z",
#   "frequency":"daily",
#   "from_date":"1980-12-12",
#   "to_date":"2014-07-03",
#   "column_names":["Date","Open","High","Low","Close","Volume","Ex-Dividend","Split Ratio","Adj. Open","Adj. High","Adj. Low","Adj. Close","Adj. Volume"],
#   "private":false,
#   "type":null,
#   "display_url":"http://www.quandl.com/WIKI/AAPL",
#   "data":[
#     ["2014-07-03",93.69,94.1,93.2,94.03,22887445.0,0.0,1.0,93.69,94.1,93.2,94.03,22887445.0],
#     ["2014-07-02",93.85,94.06,93.09,93.48,28345827.0,0.0,1.0,93.85,94.06,93.09,93.48,28345827.0],
#     ["2014-07-01",93.56,94.07,93.13,93.52,38100290.0,0.0,1.0,93.56,94.07,93.13,93.52,38100290.0]
#   ]
# }
