require 'spec_helper'

describe TransactionItemsController do

  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity, name: 'Groceries') }
  let (:transaction) { FactoryGirl.create(:transaction, entity: entity, credit_account: checking, debit_account: groceries) }
  let!(:transaction_item) { transaction.items.select{ |i| i.account_id == checking.id}.first }
  let (:creator_attributes) do
    {
      other_account_id: groceries.id,
      transaction_date: '2013-02-27',
      description: 'Market Street',
      amount: 46
    }
  end
  context 'for an authenticated user' do
    before(:each) { sign_in entity.user }
    
    context 'that owns the entity' do
      describe "get :index" do
        it 'should be successful' do
          get :index, account_id: checking
          response.should be_success
        end
        
        context 'in json' do
          it 'should be successful' do
            get :index, account_id: checking, format: :json
            response.should be_success
          end
          
          it 'should return the transactions for the account' do
            get :index, account_id: checking, format: :json
            response.body.should == [transaction_item].to_json
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'should delete the entire transation' do
          lambda do
            delete :destroy, id: transaction_item
          end.should change(Transaction, :count).by(-1)
        end
        
        it 'should delete the transation item' do
          lambda do
            delete :destroy, id: transaction_item
          end.should change(TransactionItem, :count).by(-2)
        end
        
        it 'should redirect to the account transaction items index page' do
          delete :destroy, id: transaction_item
          response.should redirect_to account_transaction_items_path(checking)
        end
        
        context 'in json' do
          it 'should delete the entire transaction' do
            lambda do
              delete :destroy, id: transaction_item, format: :json
            end.should change(Transaction, :count).by(-1)
          end
        
          it 'should delete the transaction item' do
            lambda do
              delete :destroy, id: transaction_item, format: :json
            end.should change(TransactionItem, :count).by(-2)
          end
          
          it 'should not return any data' do
            delete :destroy, id: transaction_item, format: :json
            response.body.should == ''
          end
        end
      end

      describe 'get :new' do
        it 'should be successful' do
          get :new, account_id: checking
          response.should be_success
        end
      end
      
      describe 'post :create' do
        it 'should redirect to the transaction item index page' do
          post :create, account_id: checking, transaction_item_creator: creator_attributes
          response.should redirect_to account_transaction_items_path(checking)
        end
        
        it 'should create a transaction' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes
          end.to change(Transaction, :count).by(1)
        end
        
        it 'should create two transasction items' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes
          end.to change(TransactionItem, :count).by(2)
        end
        
        context 'in json' do
          it 'should be successful' do
            post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            response.should be_success
          end
          
          it 'should create a transaction' do
            expect do
              post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            end.to change(Transaction, :count).by(1)
          end
          
          it 'should create two transasction items' do
            expect do
              post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            end.to change(TransactionItem, :count).by(2)
          end
        end
      end
      
      describe 'get :edit' do
        it 'should be successful' do
          get :edit, id: transaction_item
          response.should be_success
        end
      end
      
      describe 'put :update' do
        it 'should update the specified transaction' do
          expect do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes
            transaction.reload
          end.to change(transaction, :description).to('Market Street')
        end
        
        it 'should update the specified transaction item' do
          expect do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes
            transaction_item.reload
          end.to change(transaction_item, :amount).to(46)
        end
        
        it 'should redirect to the transaction item index page for the account' do
          put :update, id: transaction_item, transaction_item_creator: creator_attributes
          response.should redirect_to account_transaction_items_path(checking)
        end
        
        context 'in json' do
          it 'should be successful' do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
            response.should be_success
          end
        
          it 'should update the specified transaction' do
            expect do
              put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
              transaction.reload
            end.to change(transaction, :description).to('Market Street')
          end
          
          it 'should update the specified transaction item' do
            expect do
              put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
              transaction_item.reload
            end.to change(transaction_item, :amount).to(46)
          end
        end
      end
    end
    
    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe "get :index" do
        it "should redirect to the user's home page" do
          get :index, account_id: checking
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return 404' do
            get :index, account_id: checking, format: :json
            response.response_code.should == 404
          end
          
          it 'should not return any data' do
            get :index, account_id: checking, format: :json
            response.body.should == [].to_json
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'should not delete the transaction' do
          lambda do
            delete :destroy, id: transaction_item
          end.should_not change(Transaction, :count)
        end
        
        it 'should not delete the transaction item' do
          lambda do
            delete :destroy, id: transaction_item
          end.should_not change(TransactionItem, :count)
        end
        
        it 'should redirect to the entity home page' do
          delete :destroy, id: transaction_item
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return 404' do
            get :index, account_id: checking, format: :json
            response.response_code.should == 404
          end
          
          it 'should not return any data' do
            get :index, account_id: checking, format: :json
            response.body.should == [].to_json
          end
        end
      end

      describe 'get :new' do
        it 'should redirect to the home page' do
          get :new, account_id: checking
          response.should redirect_to home_path
        end
      end
      
      describe 'post :create' do
        it 'should redirect to the home page' do
          post :create, account_id: checking, transaction_item_creator: creator_attributes
          response.should redirect_to home_path
        end
        
        it 'should not create a transaction' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes
          end.not_to change(Transaction, :count)
        end
        
        it 'should not create any transasction items' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes
          end.not_to change(TransactionItem, :count)
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            response.response_code.should == 404
          end
          
          it 'should not create a transaction' do
            expect do
              post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            end.not_to change(TransactionItem, :count)
          end
        
          it 'should not create any transasction items' do
            expect do
              post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            end.not_to change(TransactionItem, :count)
          end
        end
      end
      
      describe 'get :edit' do
        it 'should redirect to the home page' do
          get :edit, id: transaction_item
          response.should redirect_to home_path
        end
      end
      
      describe 'put :update' do
        it 'should not update the specified transaction' do
          expect do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes
            transaction.reload
          end.not_to change(transaction, :description)
        end
        
        it 'should redirect to the home page' do
          put :update, id: transaction_item, transaction_item_creator: creator_attributes
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
            response.response_code.should == 404
          end
          
          it 'should not update the specified transaction' do
            expect do
              put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
              transaction.reload
            end.not_to change(transaction, :description)
          end
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe "get :index" do
      it "should redirect to the sign in page" do
        get :index, account_id: checking
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :index, account_id: checking, format: :json
          response.response_code.should == 401
        end
        
        it 'should return an error' do
          get :index, account_id: checking, format: :json
          result = JSON.parse(response.body)
          result.should have_key('error')
        end
      end
    end
      
    describe 'delete :destroy' do
      it 'should not delete the transaction' do
        lambda do
          delete :destroy, id: transaction_item
        end.should_not change(Transaction, :count)
      end
      
      it 'should not delete the transaction item' do
        lambda do
          delete :destroy, id: transaction_item
        end.should_not change(TransactionItem, :count)
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          delete :destroy, id: transaction_item, format: :json
          response.response_code.should == 401
        end
        
        it 'should not delete the transaction item' do
          lambda do
            delete :destroy, id: transaction_item, format: :json
          end.should_not change(TransactionItem, :count)
        end
      
        it 'should not delete the transaction' do
          lambda do
            delete :destroy, id: transaction_item, format: :json
          end.should_not change(Transaction, :count)
        end
      end
    end

    describe 'get :new' do
      it 'should redirect to the sign in page' do
        get :new, account_id: checking
        response.should redirect_to new_user_session_path
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, account_id: checking, transaction_item_creator: creator_attributes
        response.should redirect_to new_user_session_path
      end
      
      it 'should not create a transaction' do
        expect do
          post :create, account_id: checking, transaction_item_creator: creator_attributes
        end.not_to change(Transaction, :count)
      end
      
      it 'should not create any transasction items' do
        expect do
          post :create, account_id: checking, transaction_item_creator: creator_attributes
        end.not_to change(TransactionItem, :count)
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
          response.response_code.should == 401
        end
        
        it 'should not create a transaction' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
          end.not_to change(Transaction, :count)
        end
        
        it 'should not create any transasction items' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
          end.not_to change(TransactionItem, :count)
        end
      end
    end
      
    describe 'get :edit' do
      it 'should redirect to the sign in page' do
          get :edit, id: transaction_item
          response.should redirect_to new_user_session_path
        end
    end
    
    describe 'put :update' do
      it 'should not update the specified transaction' do
        expect do
          put :update, id: transaction_item, transaction_item_creator: creator_attributes
          transaction.reload
        end.not_to change(transaction, :description)
      end
        
      it 'should redirect to the home page' do
        put :update, id: transaction_item, transaction_item_creator: creator_attributes
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
          response.response_code.should == 401
        end
        
        it 'should not update the specified transaction' do
          expect do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
            transaction.reload
          end.not_to change(transaction, :description)
        end
      end
    end
  end
end
