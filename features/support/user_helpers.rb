module UserHelpers
  def find_user(email)
    user = User.find_by_email(email)
    expect(user).not_to be_nil
    user
  end
end
World(UserHelpers)
