require 'spec_helper'

describe TransactionsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:account) { FactoryGirl.create(:account, entity: entity, name: "Groceries", account_type: Account.expense_type) }
  let!(:account2) { FactoryGirl.create(:account, entity: entity, name: "Checking") }
  let!(:salary) { FactoryGirl.create(:account, entity: entity, name: "Salary", account_type: Account.income_type) }
  let!(:transaction) { FactoryGirl.create(:transaction, entity: entity, description: 'The payee') }
  let (:attributes) do
    {
      transaction_date: Date.new(2013, 1, 1),
      description: 'Kroger',
      items_attributes: [
        { account_id: account.id, action: TransactionItem.debit, amount: 23.32 },
        { account_id: account2.id, action: TransactionItem.credit, amount: 23.32 }
      ]
    }
  end
  
  context 'for an authenticated user' do
    context 'to which the entity belongs' do
      before(:each) { sign_in entity.user }
      
      describe "get :index" do
        it "is successful" do
          get :index, entity_id: entity
          expect(response).to be_success
        end
        
        context 'in json' do
          let!(:t1) { FactoryGirl.create(:transaction, entity: entity) }
          let!(:t2) { FactoryGirl.create(:transaction, entity: entity) }
          let!(:different_entity) { FactoryGirl.create(:transaction) }
          
          it 'is successful' do
            get :index, entity_id: entity, format: :json
            expect(response).to be_success
          end
          
          it 'returns the list of transactions' do
            get :index, entity_id: entity, format: :json
            expect(response.body).to json_match [transaction, t1, t2]
          end
        end
      end

      describe "get :new" do
        it 'is successful' do
          get :new, entity_id: entity
          expect(response).to be_success
        end
      end

      describe "post :create" do
        it "creates a new transaction" do
          expect do
            post 'create', entity_id: entity, transaction: attributes
          end.to change(Transaction, :count).by(1)
        end

        it 'creates the transaction items' do
          post 'create', entity_id: entity, transaction: attributes
          transaction = Transaction.last
          expect(transaction).to_not be_nil
          expect(transaction).to have(2).items
        end
        
        it "redirects to the index page" do
          post 'create', entity_id: entity, transaction: attributes
          expect(response).to redirect_to entity_transactions_path(entity)
        end

        context 'in json' do
          it 'creates a new transaction' do
            expect do
              post 'create', entity_id: entity, transaction: attributes, format: :json
            end.to change(Transaction, :count).by(1)
          end
          
          it 'returns the new transaction' do
            post 'create', entity_id: entity, transaction: attributes, format: :json
            returned = JSON.parse(response.body)

            # TODO Need a one-line way to do these comparisons
            attributes.each do |k, v|
              if v.is_a?(Date)
                expect(Date.parse(returned[k.to_s])).to eq(v)
              elsif v.is_a?(Array)
              else
                expect(returned[k.to_s]).to eq(v)
              end
            end

            end
        end
      end

      describe 'get :edit' do
        it 'is successful' do
          get :edit, id: transaction
          expect(response).to be_success
        end
      end

      describe "put :update" do
        let(:updated_attributes) do
          {
            description: 'Some other payee'
          }
        end
        it "updates the transaction" do
          expect do
            put :update, id: transaction, transaction: updated_attributes
            transaction.reload
          end.to change(transaction, :description).from('The payee').to('Some other payee')
        end
        
        it 'redirects to the index page' do 
          put :update, id: transaction, transaction: updated_attributes
          expect(response).to redirect_to entity_transactions_path(entity)
        end
        
        context 'in json' do
          it 'updates the transaction' do
            expect do
              put :update, id: transaction, transaction: updated_attributes, format: :json
              transaction.reload
            end.to change(transaction, :description).from('The payee').to('Some other payee')
          end
          
          it 'does not return any data' do
            put :update, id: transaction, transaction: updated_attributes, format: :json
            transaction.reload
            expect(response.body).to be_blank
          end
        end
      end

      describe "get :show" do
        it "is successful" do
          get 'show', id: transaction
          expect(response).to be_success
        end
        
        context 'in json' do
          it 'is successful' do
            get :show, id: transaction, format: :json
            expect(response).to be_success
          end
          
          it 'returns the transaction' do
            get :show, id: transaction, format: :json
            expect(response.body).to json_match transaction
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'deletes the transaction' do
          expect do
            delete :destroy, id: transaction
          end.to change(Transaction, :count).by(-1)
        end
        
        it 'redirects to the transaction index page' do
          delete :destroy, id: transaction
          expect(response).to redirect_to entity_transactions_path(entity)
        end
        
        context 'in json' do
          it 'is successful' do
            delete :destroy, id: transaction, format: :json
            expect(response).to be_success
          end
          
          it 'deletes the transaction' do
            expect do
              delete :destroy, id: transaction, format: :json
            end.to change(Transaction, :count).by(-1)
          end
        end
      end
    end

    context 'to which the account does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe 'get :index' do
        it "redirects to the entity's home page" do
          get :index, entity_id: entity
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'does not return any records' do
            get :index, entity_id: entity, format: :json            
            expect(JSON.parse(response.body)).to eq([])
          end
        end
      end
      
      describe 'get :new' do
        it 'redirects to the user home page' do
          get :new, entity_id: entity
          expect(response).to redirect_to(home_path)
        end
      end

      describe 'post :create' do
        it "redirects to the entity's home page" do
          post :create, entity_id: entity, transaction: attributes
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            post :create, entity_id: entity, transaction: attributes, format: :json
            expect(response.response_code).to eq(404)
          end
        end
      end      

      describe 'get :edit' do
        it 'redirects to the entity home page' do
          get :edit, id: transaction
          expect(response).to redirect_to(home_path)
        end
      end
      
      describe 'put :update' do
        it "redirects to the entity's home page" do
          put :update, id: transaction, entity_id: entity, transaction: attributes.merge(description: 'some new payee')
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            put :update, id: transaction, entity_id: entity, transaction: attributes.merge(description: 'some new payee'), format: :json
            expect(response.response_code).to eq(404)
          end
        end
      end      
      
      describe 'get :show' do
        it "redirects to the entity's home page" do
          get :show, id: transaction
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            get :show, id: transaction, format: :json
            expect(response.response_code).to eq(404            )
          end
        end
      end
      
      describe 'delete :destroy' do
        it "redirects to the entity's home page" do
          delete :destroy, id: transaction
          expect(response).to redirect_to home_path
        end
        
        it 'does not delete the transaction' do
          expect do
            delete :destroy, id: transaction          
          end.to_not change(Transaction, :count)
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            delete :destroy, id: transaction, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not delete the transaction' do
            expect do
              delete :destroy, id: transaction, format: :json
            end.to_not change(Transaction, :count)
          end
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the sign in page' do
        get :index, entity_id: entity
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          get :index, entity_id: entity, format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end
    
    describe 'get :new' do
      it 'redirects to the sign in page' do
        get :new, entity_id: entity
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'post :create' do
      it 'redirects to the sign in page' do
        post :create, entity_id: entity, transaction: attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          post :create, entity_id: entity, transaction: attributes, format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end

    describe 'get :edit' do
      it 'redirects to the sign in page' do
        get :edit, id: transaction
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'put :update' do
      it 'redirects to the sign in page' do
        put :update, id: transaction, entity_id: entity, transaction: attributes.merge(description: 'the new payee')
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          put :update, id: transaction, entity_id: entity, transaction: attributes.merge(description: 'the new payee'), format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end
    
    describe 'get :show' do
      it 'redirects to the sign in page' do
        get :show, id: transaction
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          get :show, id: transaction, format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end
      
    describe 'delete :destroy' do
      it "redirects to the sign in page" do
        delete :destroy, id: transaction
        expect(response).to redirect_to new_user_session_path
      end
      
      it 'does not delete the transaction' do
        expect do
          delete :destroy, id: transaction
        end.to_not change(Transaction, :count)
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          delete :destroy, id: transaction, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not delete the transaction' do
          expect do
            delete :destroy, id: transaction, format: :json
          end.to_not change(Transaction, :count)
        end
      end
    end
  end
end
