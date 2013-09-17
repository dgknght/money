require 'spec_helper'

describe TransactionsController do
  let(:account) { FactoryGirl.create(:account) }
  let(:attributes) { FactoryGirl.attributes_for(:transaction) }
  
  context 'for an authenticated user' do
    context 'to which the account belongs' do
      describe "get :index" do
        it "should be successful" do
          get :index, account_id: account
          response.should be_success
        end
        
        context 'in json' do
          it 'should be successful' do
            get :index, account_id: account, format: :json
            response.should be_success
          end
          
          it 'should return the list of transactions' do
            let!(:t1) { FactoryGirl.create(:transaction, account: account) }
            let!(:t2) { FactoryGirl.create(:transaction, account: account) }
            let!(:different_account) { FactoryGirl.create(:transaction) }
            
            get :index, account_id: account, format: :json
            response.body.should == [t1, t2].to_json
          end
        end
      end

      describe "post :create" do
        it "should create a new transaction" do
          lambda do
            post 'create', account_id: account, transaction: attributes
          end.should change(Transaction, :count).by(1)
        end
        
        it "should redirect to the index page" do
          post 'create', account_id: account, transaction: attributes
          resopnse.should redirect_to account_transactions_path(account)
        end
        
        context 'in json' do
          it 'should create a new transaction' do
            lambda do
              post 'create', account_id: account, transaction: attributes, format: :json
            end.should change(Transaction, :count).by(1)
          end
          
          it 'should return the new transaction' do
            post 'create', account_id: account, transaction: attributes, format: :json
            returned = JSON.parse(response.body)
            attributes.each do |k, v|
              returned[k].should == v
            end
          end
        end
      end

      describe "put :update" do
        it "should update the transaction"
        it 'should redirect to the index page'
        
        context 'in json' do
          it 'should update the transaction'
          it 'should return the updated transaction'
        end
      end

      describe "get :show" do
        it "should be successful" do
          get 'show', account_id: account
          response.should be_success
        end
        
        context 'in json' do
          it 'should be successful'
          it 'should return the transaction'
        end
      end
    end

    context 'to which the account does not belong' do
      describe 'get :index' do
        it 'should return "resource not found"'
        
        context 'in json' do
          it 'should return "resource not found"'
        end
      end
      
      describe 'post :create' do
        it 'should return "resource not found"'
        
        context 'in json' do
          it 'should return "resource not found"'
        end
      end      
      
      describe 'put :update' do
        it 'should return "resource not found"'
        
        context 'in json' do
          it 'should return "resource not found"'
        end
      end      
      
      describe 'get :show' do
        it 'should return "resource not found"'
        
        context 'in json' do
          it 'should return "resource not found"'
        end
      end      
    end
  end
  
  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index, account: account
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"'
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, account: account, transaction: { description: 'Kroger' }
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"'
      end
    end
    
    describe 'put :update' do
      it 'should redirect to the sign in page'
      
      context 'in json' do
        it 'should return "access denied"'
      end
    end
    
    describe 'get :show' do
      it 'should redirect to the sign in page'
      
      context 'in json' do
        it 'should return "access denied"'
      end
    end
  end
end
