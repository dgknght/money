module StockPrices
  # Mock download agent that always returns a price
  # a dollar higher than the last known price
  class DreamDownloadAgent
    def download_prices(symbol)

      Rails.logger.info "DreamDownloadAgent#download_prices #{symbol}"

      commodity = Commodity.find_by_symbol(symbol)
      return [] unless commodity

      last_known_price = last_price(commodity)
      return [] unless last_known_price

      [StockPrices::PriceRecord.new(symbol, Date.today, last_known_price + 1)]
    end

    def last_price(commodity)
      last_recorded_price(commodity) || last_lot_price(commodity)
    end

    def last_lot_price(commodity)
      commodity.lots.last.try(:price)
    end

    def last_recorded_price(commodity)
      commodity.prices.last.try(:price)
    end
  end
end
