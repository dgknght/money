Given(/^there is a user with email address "([^"]+)" and password "([^"]+)"$/) do |email, password|
  User.find_by_email(email) || User.create!(:email => email, :password => password, :password_confirmation => password)
end