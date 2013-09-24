Given(/^user "([^"]+)" has an entity named "([^"]+)"$/) do |email, name|
  user = find_user(email)
  Entity.find_by_name(name) || Entity.create!(name: name, user_id: user.id)
end