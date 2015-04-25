Given /^(#{ENTITY}) has a commodity named "([^"]+)" with symbol "([^"]+)" traded on "([^"]+)"$/ do |entity, name, symbol, market|
  entity.commodities.create!(name: name, symbol: symbol, market: market)
end

Given /^(#{ENTITY}) has the following commodities$/ do |entity, table|
  table.hashes.each do |hash|
    entity.commodities.create!( name:   hash['Name'], 
                                symbol: hash['Symbol'], 
                                market: hash['Market'])
  end
end

Given /^(#{ACCOUNT}) has the following commodity transactions$/ do |account, table|
  Timecop.freeze('2000-01-01') do
    table.hashes.each do |hash|
      value = BigDecimal.new(hash['Value'].gsub(/[^.0123456789]/, ""))
      CommodityTransactionCreator.new(account: account,
                                      transaction_date: hash['Date'],
                                      action: hash['Action'],
                                      symbol: hash['Symbol'],
                                      shares: hash['Shares'],
                                      value: value,
                                      valuation_method: CommodityTransactionCreator.fifo).create!
    end
  end
end
