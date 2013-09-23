require 'spec_helper'

describe User do
  let (:user) { FactoryGirl.create(:user) }

  let!(:other_user) { FactoryGirl.create(:account) }
  
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
      user = User.new(attributes.without(:email))
      user.should_not be_valid
    end
  end
  
  describe 'entities' do
    let!(:entity1) { FactoryGirl.create(:entity, user: user) }
    let!(:entity2) { FactoryGirl.create(:entity, user: user) }
    let!(:someone_else) { FactoryGirl.create(:entity) }
    it 'should list the entities that belong to the user' do
      user.entities.should == [entity1, entity2]
    end
  end
end
