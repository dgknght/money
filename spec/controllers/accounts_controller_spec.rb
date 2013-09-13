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
    
    describe 'get :new' do
      it 'should be successful' do
        get :new
        response.should be_success
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the detail page for the new account' do
        post :create, :account => FactoryGirl.attributes_for(:account)
        response.should redirect_to account_path(Account.last)
      end
      
      context 'in json' do
        it 'should create a new account' do
          lambda do
            post :create, :account => FactoryGirl.attributes_for(:account), :format => :json
          end.should change(Account, :count).by(1)
        end
        
        it 'should return the new account' do
          attributes = FactoryGirl.attributes_for(:account)
          post :create, :account => attributes, :format => :json
          actual = JSON.parse(response.body)
          attributes.each { |k, v| actual[k.to_s].to_s.should == v.to_s }
        end
      end
    end

    describe 'get :show' do
      it 'should be successful' do
        get :show, :id => checking
        response.should be_success
      end
      
      context 'in json' do
        it 'should return the specified account' do
          get :show, :id => checking, :format => :json
          response.body.should == checking.to_json
        end
      end     
    end
    
    describe 'get :edit' do
      it 'should be successful' do
        get :edit, :id => checking
        response.should be_success
      end
    end
    
    describe 'put :update' do
      it 'should redirect to the detail page for the specified account' do
        put :update, :id => checking, :account => { :name => 'The new name' }
        response.should redirect_to account_path(checking)
      end
      
      it 'should update the account' do
        lambda do
          put :update, :id => checking, :account => { :name => 'The new name' }
          checking.reload
        end.should change(checking, :name).from('checking').to('The new name')
      end
      
      context 'in json' do
        it 'should update the account' do
          lambda do
            put :update, :id => checking, :account => { :name => 'The new name' }, :format => :json
            checking.reload
          end.should change(checking, :name).from('checking').to('The new name')
        end
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
    
    describe 'get :new' do
      it 'should be redirect to the sign in page' do
        get :new
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :new, :format => :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, :account => FactoryGirl.attributes_for(:account)
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          post :create, :account => FactoryGirl.attributes_for(:account), :format => :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'get :show' do
      it 'should redirect to the sign in page' do
          get :show, :id => checking
          response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :show, :id => checking, :format => :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'get :edit' do
      it 'should redirect to the sign in page' do
        get :edit, :id => checking
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :edit, :id => checking, :format => :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'put :update' do
      it 'should redirect to the sign in page' do
        put :update, :id => checking, :account => { name: 'The new name' }
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          put :update, :id => checking, :account => { name: 'The new name' }, :format => :json
          response.response_code.should == 401
        end
      end
    end
  end
end