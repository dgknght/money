Given(/^(#{ENTITY}) has a budget named "([^"]+)" starting on (#{DATE_VALUE}) and ending on (#{DATE_VALUE})$/) do |entity, name, start_date, end_date|
  entity.budgets.create!(name: name, start_date: start_date, end_date: end_date)
end