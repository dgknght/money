After do |scenario|
  save_and_open_page if scenario.failed? && ENV['SHOW_FAILURES']
end

After('@timecop') do |scenario|
  Timecop.return
end
