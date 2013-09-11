Given(/^I am on the (.*) page$/) do |page_identifier|
  visit path_for(page_identifier)
end

Given(/^I fill in "([^"]+)" with "([^"]+)"$/) do |locator, value|
  fill_in locator, :with => value
end

When(/^I click "([^"]+)"$/) do |locator|
  click_on(locator)
end

Then(/^I should see "([^"]+)"$/) do |content|
  page.should have_content(content)
end

When /^(.*) within (.*)$/ do |step_content, section|
  locator, content  = locator_for(section)
  scope = content ? find(locator, :text => content) : find(locator)
  within(scope) { step(step_content) }
end