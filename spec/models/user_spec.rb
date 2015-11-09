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

  it 'is creatable given valid parameters' do
    user = User.new(attributes)
    expect(user).not_to be_nil
    expect(user).to be_valid
  end
  
  describe 'email' do
    it 'is required' do
      user = User.new(attributes.without(:email))
      expect(user).not_to be_valid
    end
  end
  
  describe 'entities' do
    let!(:entity1) { FactoryGirl.create(:entity, user: user) }
    let!(:entity2) { FactoryGirl.create(:entity, user: user) }
    let!(:someone_else) { FactoryGirl.create(:entity) }
    it 'lists the entities that belong to the user' do
      expect(user.entities).to eq([entity1, entity2])
    end
  end
end
