Given (/^today is (#{DATE_VALUE})$/) do |date|
  Timecop.freeze(date)
end
