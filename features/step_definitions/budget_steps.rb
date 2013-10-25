Given(/^(#{ENTITY}) has a (\d+)-(week|month|year) budget named "([^"]+)" starting on (#{DATE_VALUE})$/) do |entity, period_count, period, name, start_date|
  entity.budgets.create!(name: name, start_date: start_date, period: period, period_count: period_count)
end