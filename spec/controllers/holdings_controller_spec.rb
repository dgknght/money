require 'spec_helper'

describe HoldingsController do

  let (:account) { FactoryGirl.create(:account) }

  context 'for an authenticated user' do
    context 'that owns the entity' do
      before(:each) { sign_in account.entity.user }

    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user} 
    end
  end

  context 'for an unauthenticated user' do
  end
end
