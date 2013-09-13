Given (/^I am on (.*) page$/) do |page_identifier|
  visit path_for(page_identifier)
end

Given (/^I fill in "([^"]+)" with "([^"]+)"$/) do |locator, value|
  fill_in locator, :with => value
end

When (/^I click "([^"]+)"$/) do |locator|
  click_on(locator)
end

Then (/^I should see "([^"]+)"$/) do |content|
  page.should have_content(content)
end

When (/^(.*) within (.*)$/) do |step_content, section|
  locator, content  = locator_for(section)
  scope = content ? find(locator, :text => content) : find(locator)
  within(scope) { step(step_content) }
end

Then (/^I should see the following (.*) table$/) do |description, expected_table|
  id = "##{description_to_id(description)}_table"
  html_table = find(id)
  actual_table = parse_table(html_table)
  expected_table.diff!(actual_table)
end

Then (/^I should see the following (.*) attributes$/) do |description, expected_table|
  id = "##{description_to_id(description)}_table"
  html_table = find(id)
  actual_table = parse_table(html_table)
  expected_table.diff!(actual_table)
end

Then (/^show me the page$/) do
  save_and_open_page
end