require 'spec_helper'

describe TestsController do

  let(:user) { FactoryGirl.create(:user) }

  context 'for an authenticated user' do
    before(:each) { sign_in user }

    describe 'get :index' do
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it "should redirect to the sign in page" do
        get 'index'
        response.should redirect_to new_user_session_path
      end
    end
  end
end
