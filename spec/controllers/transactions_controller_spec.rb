require 'spec_helper'

describe TransactionsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:account) { FactoryGirl.create(:account, user: user) }
  let(:transaction) { FactoryGirl.create(:transaction, user: user) }
  let(:attributes) { FactoryGirl.attributes_for(:transaction, user: user) }
  
  context 'for an authenticated user' do
    context 'to which the account belongs' do
      before(:each) { sign_in user }
      
      describe "get :index" do
        it "should be successful" do
          get :index, account_id: account
          response.should be_success
        end
        
        context 'in json' do
          let (:t1) { FactoryGirl.create(:transaction, user: user) }
          let!(:i1) { FactoryGirl.create(:transaction_item, transaction: t1, account: account) }
          let!(:i2) { FactoryGirl.create(:transaction_item, transaction: t1) }
          let (:t2) { FactoryGirl.create(:transaction, user: user) }
          let!(:i3) { FactoryGirl.create(:transaction_item, transaction: t2, account: account) }
          let!(:i4) { FactoryGirl.create(:transaction_item, transaction: t2) }
          let (:different_account) { FactoryGirl.create(:transaction, user: user) }
          let!(:i5) { FactoryGirl.create(:transaction_item, transaction: t2) }
          let!(:i6) { FactoryGirl.create(:transaction_item, transaction: t2) }
          
          it 'should be successful' do
            get :index, account_id: account, format: :json
            response.should be_success
          end
          
          it 'should return the list of transactions' do
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
          response.should redirect_to account_transactions_path(account)
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
              returned[k.to_s].should == v
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
          get 'show', id: transaction
          response.should be_success
        end
        
        context 'in json' do
          it 'should be successful'
          it 'should return the transaction'
        end
      end
    end

    context 'to which the account does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
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
        get :index, account_id: account
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"'
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, account_id: account, transaction: attributes
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
