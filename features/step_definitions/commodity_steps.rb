Given /^(#{ENTITY}) has a commodity named "([^"]+)" with symbol "([^"]+)" traded on "([^"]+)"$/ do |entity, name, symbol, market|
  entity.commodities.create!(name: name, symbol: symbol, market: market)
end
