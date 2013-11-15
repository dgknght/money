require 'spec_helper'

describe TransactionItemsController do

  let (:account) { FactoryGirl.create(:asset_account) }
  
  context 'for an authenticated user' do
    before(:each) { sign_in account.entity.user }
    
    context 'that owns the entity' do
      describe "get :index" do
        it 'should be successful' do
          get :index, account_id: account
          response.should be_success
        end
      end
    end
    
    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe "get :index" do
        it "should redirect to the user's home page" do
          get :index, account_id: account
          response.should redirect_to home_path
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe "get :index" do
      it "should redirect to the sign in page" do
        get :index, account_id: account
        response.should redirect_to new_user_session_path
      end
    end
  end
end
