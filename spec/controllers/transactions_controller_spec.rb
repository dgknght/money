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
        it "should be successful" do
          get :index, entity_id: entity
          response.should be_success
        end
        
        context 'in json' do
          let!(:t1) { FactoryGirl.create(:transaction, entity: entity) }
          let!(:t2) { FactoryGirl.create(:transaction, entity: entity) }
          let!(:different_entity) { FactoryGirl.create(:transaction) }
          
          it 'should be successful' do
            get :index, entity_id: entity, format: :json
            response.should be_success
          end
          
          it 'should return the list of transactions' do
            get :index, entity_id: entity, format: :json
            response.body.should == [transaction, t1, t2].to_json
          end
        end
      end

      describe "post :create" do
        it "should create a new transaction" do
          lambda do
            post 'create', entity_id: entity, transaction: attributes
          end.should change(Transaction, :count).by(1)
        end

        it 'should create the transaction items' do
          post 'create', entity_id: entity, transaction: attributes
          transaction = Transaction.last
          transaction.should_not be_nil
          transaction.should have(2).items
        end
        
        it "should redirect to the index page" do
          post 'create', entity_id: entity, transaction: attributes
          response.should redirect_to entity_transactions_path(entity)
        end

        context 'in json' do
          it 'should create a new transaction' do
            lambda do
              post 'create', entity_id: entity, transaction: attributes, format: :json
            end.should change(Transaction, :count).by(1)
          end
          
          it 'should return the new transaction' do
            post 'create', entity_id: entity, transaction: attributes, format: :json
            returned = JSON.parse(response.body)

            # TODO Need a one-line way to do these comparisons
            attributes.each do |k, v|
              if v.is_a?(Date)
                Date.parse(returned[k.to_s]).should == v
              elsif v.is_a?(Array)
              else
                returned[k.to_s].should == v
              end
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
            put :update, id: transaction, transaction: updated_attributes
            transaction.reload
          end.should change(transaction, :description).from('The payee').to('Some other payee')
        end
        
        it 'should redirect to the index page' do 
          put :update, id: transaction, transaction: updated_attributes
          response.should redirect_to entity_transactions_path(entity)
        end
        
        context 'in json' do
          it 'should update the transaction' do
            lambda do
              put :update, id: transaction, transaction: updated_attributes, format: :json
              transaction.reload
            end.should change(transaction, :description).from('The payee').to('Some other payee')
          end
          
          it 'should not return any data' do
            put :update, id: transaction, transaction: updated_attributes, format: :json
            transaction.reload
            response.body.should == ""
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
      
      describe 'delete :destroy' do
        it 'should delete the transaction' do
          lambda do
            delete :destroy, id: transaction
          end.should change(Transaction, :count).by(-1)
        end
        
        it 'should redirect to the transaction index page' do
          delete :destroy, id: transaction
          response.should redirect_to entity_transactions_path(entity)
        end
        
        context 'in json' do
          it 'should be successful' do
            delete :destroy, id: transaction, format: :json
            response.should be_success
          end
          
          it 'should delete the transaction' do
            lambda do
              delete :destroy, id: transaction, format: :json
            end.should change(Transaction, :count).by(-1)
          end
        end
      end
    end

    context 'to which the account does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe 'get :index' do
        it "should redirect to the entity's home page" do
          get :index, entity_id: entity
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should not return any records' do
            get :index, entity_id: entity, format: :json            
            JSON.parse(response.body).should == []
          end
        end
      end
      
      describe 'post :create' do
        it "should redirect to the entity's home page" do
          post :create, entity_id: entity, transaction: attributes
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            post :create, entity_id: entity, transaction: attributes, format: :json
            response.response_code.should == 404
          end
        end
      end      
      
      describe 'put :update' do
        it "should redirect to the entity's home page" do
          put :update, id: transaction, entity_id: entity, transaction: attributes.merge(description: 'some new payee')
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            put :update, id: transaction, entity_id: entity, transaction: attributes.merge(description: 'some new payee'), format: :json
            response.response_code.should == 404
          end
        end
      end      
      
      describe 'get :show' do
        it "should redirect to the entity's home page" do
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
      
      describe 'delete :destroy' do
        it "should redirect to the entity's home page" do
          delete :destroy, id: transaction
          response.should redirect_to home_path
        end
        
        it 'should not delete the transaction' do
          lambda do
            delete :destroy, id: transaction          
          end.should_not change(Transaction, :count)
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            delete :destroy, id: transaction, format: :json
            response.response_code.should == 404
          end
          
          it 'should not delete the transaction' do
            lambda do
              delete :destroy, id: transaction, format: :json
            end.should_not change(Transaction, :count)
          end
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index, entity_id: entity
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :index, entity_id: entity, format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, entity_id: entity, transaction: attributes
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          post :create, entity_id: entity, transaction: attributes, format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'put :update' do
      it 'should redirect to the sign in page' do
        put :update, id: transaction, entity_id: entity, transaction: attributes.merge(description: 'the new payee')
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          put :update, id: transaction, entity_id: entity, transaction: attributes.merge(description: 'the new payee'), format: :json
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
      
    describe 'delete :destroy' do
      it "should redirect to the sign in page" do
        delete :destroy, id: transaction
        response.should redirect_to new_user_session_path
      end
      
      it 'should not delete the transaction' do
        lambda do
          delete :destroy, id: transaction
        end.should_not change(Transaction, :count)
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          delete :destroy, id: transaction, format: :json
          response.response_code.should == 401
        end
        
        it 'should not delete the transaction' do
          lambda do
            delete :destroy, id: transaction, format: :json
          end.should_not change(Transaction, :count)
        end
      end
    end
  end
end
