Given(/^there is a user with email address "([^"]+)" and password "([^"]+)"$/) do |email, password|
  User.find_by_email(email) || User.create!(:email => email, :password => password, :password_confirmation => password)
end

Given(/^I am signed in as "([^\/]+)\/(.*)"$/) do |email, password|
  visit new_user_session_path
  fill_in 'Email', :with => email
  fill_in 'Password', :with => password
  click_on 'Sign in'
#  page.should have_content('Sign out')
end