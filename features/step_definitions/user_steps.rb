Given(/^there is a user with email address "([^"]+)" and password "([^"]+)"$/) do |email, password|
  User.find_by_email(email) || User.create!(:email => email, :password => password, :password_confirmation => password)
end

Given(/^I am signed in as "([^\/]+)\/(.*)"$/) do |email, password|
  visit new_user_session_path
  fill_in 'Email', :with => email
  fill_in 'Password', :with => password
  within(:css, '#main-content') do
    click_button 'Sign in'
  end
  within(:css, 'nav') do
    expect(page).to have_content('Sign out')
  end
end
