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
        it 'is successful' do
          get :index, account_id: checking
          expect(response).to be_success
        end
        
        context 'in json' do
          it 'is successful' do
            get :index, account_id: checking, format: :json
            expect(response).to be_success
          end
          
          it 'returns the transactions for the account' do
            get :index, account_id: checking, format: :json
            expect(response.body).to json_match [transaction_item]
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'deletes the entire transation' do
          expect do
            delete :destroy, id: transaction_item
          end.to change(Transaction, :count).by(-1)
        end
        
        it 'deletes the transation item' do
          expect do
            delete :destroy, id: transaction_item
          end.to change(TransactionItem, :count).by(-2)
        end
        
        it 'redirects to the account transaction items index page' do
          delete :destroy, id: transaction_item
          expect(response).to redirect_to account_transaction_items_path(checking)
        end
        
        context 'in json' do
          it 'deletes the entire transaction' do
            expect do
              delete :destroy, id: transaction_item, format: :json
            end.to change(Transaction, :count).by(-1)
          end
        
          it 'deletes the transaction item' do
            expect do
              delete :destroy, id: transaction_item, format: :json
            end.to change(TransactionItem, :count).by(-2)
          end
          
          it 'does not return any data' do
            delete :destroy, id: transaction_item, format: :json
            expect(response.body).to be_blank
          end
        end
      end

      describe 'get :new' do
        it 'is successful' do
          get :new, account_id: checking
          expect(response).to be_success
        end
      end
      
      describe 'post :create' do
        it 'redirects to the transaction item index page' do
          post :create, account_id: checking, transaction_item_creator: creator_attributes
          expect(response).to redirect_to account_transaction_items_path(checking)
        end
        
        it 'creates a transaction' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes
          end.to change(Transaction, :count).by(1)
        end
        
        it 'creates two transasction items' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes
          end.to change(TransactionItem, :count).by(2)
        end
        
        context 'in json' do
          it 'is successful' do
            post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            expect(response).to be_success
          end
          
          it 'creates a transaction' do
            expect do
              post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            end.to change(Transaction, :count).by(1)
          end
          
          it 'creates two transasction items' do
            expect do
              post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            end.to change(TransactionItem, :count).by(2)
          end
        end
      end
      
      describe 'get :edit' do
        it 'is successful' do
          get :edit, id: transaction_item
          expect(response).to be_success
        end
      end
      
      describe 'put :update' do
        it 'updates the specified transaction' do
          expect do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes
            transaction.reload
          end.to change(transaction, :description).to('Market Street')
        end
        
        it 'updates the specified transaction item' do
          expect do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes
            transaction_item.reload
          end.to change(transaction_item, :amount).to(46)
        end
        
        it 'redirects to the transaction item index page for the account' do
          put :update, id: transaction_item, transaction_item_creator: creator_attributes
          expect(response).to redirect_to account_transaction_items_path(checking)
        end
        
        context 'in json' do
          it 'is successful' do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
            expect(response).to be_success
          end
        
          it 'updates the specified transaction' do
            expect do
              put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
              transaction.reload
            end.to change(transaction, :description).to('Market Street')
          end
          
          it 'updates the specified transaction item' do
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
        it "redirects to the user's home page" do
          get :index, account_id: checking
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns 404' do
            get :index, account_id: checking, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :index, account_id: checking, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'does not delete the transaction' do
          expect do
            delete :destroy, id: transaction_item
          end.to_not change(Transaction, :count)
        end
        
        it 'does not delete the transaction item' do
          expect do
            delete :destroy, id: transaction_item
          end.to_not change(TransactionItem, :count)
        end
        
        it 'redirects to the entity home page' do
          delete :destroy, id: transaction_item
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns 404' do
            get :index, account_id: checking, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :index, account_id: checking, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :new' do
        it 'redirects to the home page' do
          get :new, account_id: checking
          expect(response).to redirect_to home_path
        end
      end
      
      describe 'post :create' do
        it 'redirects to the home page' do
          post :create, account_id: checking, transaction_item_creator: creator_attributes
          expect(response).to redirect_to home_path
        end
        
        it 'does not create a transaction' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes
          end.not_to change(Transaction, :count)
        end
        
        it 'does not create any transasction items' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes
          end.not_to change(TransactionItem, :count)
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not create a transaction' do
            expect do
              post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            end.not_to change(TransactionItem, :count)
          end
        
          it 'does not create any transasction items' do
            expect do
              post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
            end.not_to change(TransactionItem, :count)
          end
        end
      end
      
      describe 'get :edit' do
        it 'redirects to the home page' do
          get :edit, id: transaction_item
          expect(response).to redirect_to home_path
        end
      end
      
      describe 'put :update' do
        it 'does not update the specified transaction' do
          expect do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes
            transaction.reload
          end.not_to change(transaction, :description)
        end
        
        it 'redirects to the home page' do
          put :update, id: transaction_item, transaction_item_creator: creator_attributes
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not update the specified transaction' do
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
      it "redirects to the sign in page" do
        get :index, account_id: checking
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          get :index, account_id: checking, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error' do
          get :index, account_id: checking, format: :json
          result = JSON.parse(response.body)
          expect(result).to have_key('error')
        end
      end
    end
      
    describe 'delete :destroy' do
      it 'does not delete the transaction' do
        expect do
          delete :destroy, id: transaction_item
        end.to_not change(Transaction, :count)
      end
      
      it 'does not delete the transaction item' do
        expect do
          delete :destroy, id: transaction_item
        end.to_not change(TransactionItem, :count)
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          delete :destroy, id: transaction_item, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not delete the transaction item' do
          expect do
            delete :destroy, id: transaction_item, format: :json
          end.to_not change(TransactionItem, :count)
        end
      
        it 'does not delete the transaction' do
          expect do
            delete :destroy, id: transaction_item, format: :json
          end.to_not change(Transaction, :count)
        end
      end
    end

    describe 'get :new' do
      it 'redirects to the sign in page' do
        get :new, account_id: checking
        expect(response).to redirect_to new_user_session_path
      end
    end
    
    describe 'post :create' do
      it 'redirects to the sign in page' do
        post :create, account_id: checking, transaction_item_creator: creator_attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      it 'does not create a transaction' do
        expect do
          post :create, account_id: checking, transaction_item_creator: creator_attributes
        end.not_to change(Transaction, :count)
      end
      
      it 'does not create any transasction items' do
        expect do
          post :create, account_id: checking, transaction_item_creator: creator_attributes
        end.not_to change(TransactionItem, :count)
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not create a transaction' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
          end.not_to change(Transaction, :count)
        end
        
        it 'does not create any transasction items' do
          expect do
            post :create, account_id: checking, transaction_item_creator: creator_attributes, format: :json
          end.not_to change(TransactionItem, :count)
        end
      end
    end
      
    describe 'get :edit' do
      it 'redirects to the sign in page' do
          get :edit, id: transaction_item
          expect(response).to redirect_to new_user_session_path
        end
    end
    
    describe 'put :update' do
      it 'does not update the specified transaction' do
        expect do
          put :update, id: transaction_item, transaction_item_creator: creator_attributes
          transaction.reload
        end.not_to change(transaction, :description)
      end
        
      it 'redirects to the home page' do
        put :update, id: transaction_item, transaction_item_creator: creator_attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not update the specified transaction' do
          expect do
            put :update, id: transaction_item, transaction_item_creator: creator_attributes, format: :json
            transaction.reload
          end.not_to change(transaction, :description)
        end
      end
    end
  end
end
