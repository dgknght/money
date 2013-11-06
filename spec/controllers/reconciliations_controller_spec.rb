require 'spec_helper'

describe ReconciliationsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }

  context 'for an authenticated user' do
    
    context 'to which the entity belongs' do
      before(:each) { sign_in entity.user }
      
      describe "get :new" do
        it 'should be successful' do
          get :new, account_id: checking
          response.should be_success
        end
      end

      describe "post :create" do
        it 'should create the reconciliation'
        it 'should redirect to the reconciliation detail page'
        context 'in json' do
          it 'should be successful'
          it 'should create the reconciliation'
        end
      end
    end
    
    context 'to which the entity does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }
      
      describe "get :new" do
        it "should redirect to the user's home page" do
          get :new, account_id: checking
          response.should redirect_to home_path
        end
      end

      describe "post :create" do
        it "should redirect to the user's home page"
        it 'should not create the reconciliation'
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not create the reconciliation'
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe "get :new" do
      it 'should redirect to the sign in page' do
        get :new, account_id: checking
        response.should redirect_to new_user_session_path
      end
    end

    describe "post :create" do
      it 'should redirect to the sign in page'
      it 'should not create a reconciliation'
      context 'in json' do
        it 'should return "access denied"'
        it 'should not create the reconciliation'
      end
    end
  end
end
