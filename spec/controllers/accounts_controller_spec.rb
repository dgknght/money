require 'spec_helper'

describe AccountsController do
  let (:user) { FactoryGirl.create(:user) }
  let!(:checking) { FactoryGirl.create(:account, :user => user, :name => 'checking') }
  let!(:cash) { FactoryGirl.create(:account, :user => user, :name => 'cash') }
  
  context 'for an authenticated user' do
    before(:each) { sign_in user }
    
    describe 'get :index' do
      it 'should be successful' do
        get :index
        response.should be_success
      end
    end
    
    context 'in json' do
      it 'should be successful' do
        get :index, :format => :json
        response.should be_success
      end
      
      it 'should return the list of accounts' do
        get :index, :format => :json
        response.body.should == [checking, cash].to_json
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index
        response.should redirect_to new_user_session_path
      end
    end
    
    context 'in json' do
      it 'should return "access denied"' do
        get :index, :format => :json
        response.response_code.should == 401
      end
    end
  end
end