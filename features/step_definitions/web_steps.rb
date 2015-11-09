Given (/^I am on (.*) page$/) do |page_identifier|
  visit path_for(page_identifier)
end

When (/^I fill in "([^"]+)" with "([^"]+)"$/) do |locator, value|
  fill_in locator, :with => value
end

When (/^I fill in the (\d(?:st|nd|rd|th)) (\w+) (\w+) (\w+) field with "([^"]+)"$/) do |ordinal, parent, child, description, value|
  locator = "#{parent}[#{child}_attributes][#{ordinal_to_index(ordinal)}][#{description}]"
  fill_in locator, :with => value
end

When (/^I click (?:on )?"([^"]+)"$/) do |locator|
  click_on(locator)
end

When (/^I check the box$/) do
  checkbox = find('input[type=checkbox]')
  checkbox.set(true)
end

When (/^I select "([^"]+)" from the "([^"]+)" list$/) do |value, locator|
  select value, from: locator
end

When (/^I select "([^"]+)" from the (\d(?:st|nd|rd|th)) (\w+) (\w+) (\w+) list$/) do |value, ordinal, parent, child, description|
  locator = "#{parent}[#{child}_attributes][#{ordinal_to_index(ordinal)}][#{description}]"
  select value, from: locator
end

Then (/^I should see "([^"]+)"$/) do |content|
  expect(page).to have_content(content)
end

Then (/^I should not see "([^"]+)"$/) do |content|
  expect(page).not_to have_content(content)
end

When (/^(.*) within (.*)$/) do |step_content, section|
  locator, content  = locator_for(section)
  scope = content ? find(locator, :text => content) : find(locator)
  within(scope) { step(step_content) }
end

When (/^I specify the file "([^"]+)" for "([^"]+)"$/) do |file, locator|
  path = Rails.root.join('features', 'resources', file)
  attach_file(locator, path)
end

When (/^I click the (.*) button$/) do |button_type|
  find(".#{button_type}_button").click
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

Then (/I should see an image/) do
  expect(response_headers).to include('Content-Type' => 'image/png')
end
