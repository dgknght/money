Given(/^I am on the (.*) page$/) do |page_identifier|
  path = case page_identifier
    when "not a real one" then "test"
#    when "home" then "/"
    else raise "unrecognized page identifier #{page_identifier}"
  end
  visit path
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