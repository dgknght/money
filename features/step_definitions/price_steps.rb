COMMODITY = Transform(/^commodity "([^"]+)"$/) do |symbol|
  result = Commodity.find_by_symbol(symbol)
  expect(result).not_to be_nil
  result
end

Given /^(#{COMMODITY}) has the following prices$/ do |commodity, table|
  table.hashes.each do |hash|
    commodity.prices.create!(trade_date: hash['Trade date'], price: hash['Price'])
  end
end
