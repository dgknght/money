require 'spec_helper'

describe User do
  let(:attributes) do
    {
      :email => 'test_user@test.com',
      :password => 'please01',
      :password_confirmation => 'please01'
    }
  end

  it 'should be creatable given valid parameters' do
    user = User.new(attributes)
    user.should_not be_nil
    user.should be_valid
  end
  
  describe 'email' do
    it 'should be required' do
      user = User.new(attributes.reject {|k, v| k == :email})
      user.should_not be_valid
    end
  end
end