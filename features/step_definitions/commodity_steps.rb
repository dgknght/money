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
  table.hashes.each do |hash|
    attributes = {
      transaction_date: hash['Date'],
      action: hash['Action'],
      symbol: hash['Symbol'],
      price: hash['Price'],
      shares: hash['Shares'],
      value: hash['Value']
    }
    creator = TransactionCommodityCreator.new(account, attributes)
    creator.create!
  end
end
