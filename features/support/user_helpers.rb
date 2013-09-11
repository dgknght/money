module UserHelpers
  def find_user(email)
    user = User.find_by_email(email)
    user.should_not be_nil
    user
  end
end
World(UserHelpers)