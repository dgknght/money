require 'spec_helper'

describe TransactionsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:account) { FactoryGirl.create(:account, user: user) }
  let(:account2) { FactoryGirl.create(:account, user: user) }
  let(:transaction) { FactoryGirl.create(:transaction, user: user, description: 'The payee') }
  let(:attributes) do
    {
      transaction_date: '1/1/2013',
      description: 'Kroger',
      items_attributes: [
        { account_id: account, action: :debit, amount: 23.32 },
        { account_id: account2, action: :credit, amount: 23.32 }        
      ]
    }
  end
  
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
        
        it 'should create the transaction items' do
          post 'create', account_id: account, transaction: attributes
          transaction = Transaction.last
          transaction.should have(2).items
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
        let(:updated_attributes) do
          {
            description: 'Some other payee'
          }
        end
        it "should update the transaction" do
          lambda do
            put :update, id: transaction, account_id: account, transaction: updated_attributes
            transaction.reload
          end.should change(transaction, :description).from('The payee').to('Some other payee')
        end
        
        it 'should redirect to the index page' do 
          put :update, id: transaction, account_id: account, transaction: updated_attributes
          response.should redirect_to account_transactions_path(account)
        end
        
        context 'in json' do
          it 'should update the transaction' do
            lambda do
              put :update, id: transaction, account_id: account, transaction: updated_attributes, format: :json
              transaction.reload
            end.should change(transaction, :description).from('The payee').to('Some other payee')
          end
          
          it 'should not return any data' do
            put :update, id: transaction, account_id: account, transaction: updated_attributes, format: :json
            transaction.reload
            response.body.should == " "
          end
        end
      end

      describe "get :show" do
        it "should be successful" do
          get 'show', id: transaction
          response.should be_success
        end
        
        context 'in json' do
          it 'should be successful' do
            get :show, id: transaction, format: :json
            response.should be_success
          end
          
          it 'should return the transaction' do
            get :show, id: transaction, format: :json
            response.body.should == transaction.to_json
          end
        end
      end
    end

    context 'to which the account does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe 'get :index' do
        it "should redirect to the user's home page" do
          get :index, account_id: account
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should not return any records' do
            get :index, account_id: account, format: :json            
            JSON.parse(response.body).should == []
          end
        end
      end
      
      describe 'post :create' do
        it "should redirect to the user's home page" do
          post :create, account_id: account, transaction: attributes
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            post :create, account_id: account, transaction: attributes, format: :json
            response.response_code.should == 404
          end
        end
      end      
      
      describe 'put :update' do
        it "should redirect to the user's home page" do
          put :update, id: transaction, account_id: account, transaction: attributes.merge(description: 'some new payee')
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            put :update, id: transaction, account_id: account, transaction: attributes.merge(description: 'some new payee'), format: :json
            response.response_code.should == 404
          end
        end
      end      
      
      describe 'get :show' do
        it "should redirect to the user's home page" do
          get :show, id: transaction
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            get :show, id: transaction, format: :json
            response.response_code.should == 404            
          end
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
        it 'should return "access denied"' do
          get :index, account_id: account, format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, account_id: account, transaction: attributes
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          post :create, account_id: account, transaction: attributes, format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'put :update' do
      it 'should redirect to the sign in page' do
        put :update, id: transaction, account_id: account, transaction: attributes.merge(description: 'the new payee')
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          put :update, id: transaction, account_id: account, transaction: attributes.merge(description: 'the new payee'), format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'get :show' do
      it 'should redirect to the sign in page' do
        get :show, id: transaction
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :show, id: transaction, format: :json
          response.response_code.should == 401
        end
      end
    end
  end
end
