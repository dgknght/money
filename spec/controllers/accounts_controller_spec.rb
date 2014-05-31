require 'spec_helper'

describe AccountsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:checking) { FactoryGirl.create(:account, entity: entity, name: 'checking') }
  let!(:cash) { FactoryGirl.create(:account, entity: entity, name: 'cash') }
  let (:ira) { FactoryGirl.create(:commodity_account, entity: entity, name: 'IRA') }
  
  context 'for an authenticated user' do
    context 'that owns the entity' do
      before(:each) { sign_in entity.user }
      
      describe 'get :index' do
        it 'should be successful' do
          get :index, entity_id: entity
          response.should be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :index, entity_id: entity, format: :json
            response.should be_success
          end
          
          it 'should return the list of accounts' do
            get :index, entity_id: entity, format: :json
            response.body.should == [checking, cash].to_json
          end
        end
      end

      describe 'get :new' do
        it 'should be successful' do
          get :new, entity_id: entity
          response.should be_success
        end
      end
    
      describe 'post :create' do
        it 'should redirect to the account list page' do
          post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account)
          response.should redirect_to entity_accounts_path(entity)
        end
        
        context 'in json' do
          it 'should create a new account' do
            lambda do
              post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account), format: :json
            end.should change(Account, :count).by(1)
          end
          
          it 'should return the new account' do
            attributes = FactoryGirl.attributes_for(:account)
            post :create, entity_id: entity, account: attributes, format: :json
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
            get :show, id: checking, format: :json
            response.body.should == checking.to_json
          end
        end     
      end
    
      describe 'get :edit' do
        it 'should be successful' do
          get :edit, id: checking
          response.should be_success
        end
      end
    
      describe 'put :update' do
        it 'should redirect to the account list page' do
          put :update, id: checking, account: { name: 'The new name' }
          response.should redirect_to entity_accounts_path(entity)
        end
        
        it 'should update the account' do
          lambda do
            put :update, id: checking, account: { name: 'The new name' }
            checking.reload
          end.should change(checking, :name).from('checking').to('The new name')
        end
        
        context 'in json' do
          it 'should update the account' do
            lambda do
              put :update, id: checking, account: { name: 'The new name' }, format: :json
              checking.reload
            end.should change(checking, :name).from('checking').to('The new name')
          end
        end
      end
  
      describe 'delete :destroy' do
        it 'should redirect to the account list page' do
          delete :destroy, id: checking
          response.should redirect_to entity_accounts_path(entity)
        end
        
        it 'should delete the specified account' do
          lambda do
            delete :destroy, id: checking
          end.should change(Account, :count).by(-1)
        end
        
        context 'in json' do
          it 'should be successful' do
            delete :destroy, id: checking, format: :json
            response.should be_success
          end
          
          it 'should delete the specified account' do
            lambda do
              delete :destroy, id: checking, format: :json
            end.should change(Account, :count).by(-1)
          end
        end
      end

      describe 'get :new_purchase' do
        it 'be successful' do
          get :new_purchase, id: ira
          expect(response).to be_success
        end
      end

      describe 'post :create_purchase' do
        let!(:kss) { FactoryGirl.create(:commodity, symbol: 'KSS') }
        let (:purchase_attributes) do
          {
            transaction_date: '2014-01-01',
            symbol: 'KSS',
            action: 'buy',
            shares: 100,
            value: 1_000
          }
        end

        it 'should redirect to the holdings page' do
          post :create_purchase, id: ira, purchase: purchase_attributes
          expect(response).to redirect_to account_holdings_path(ira)
        end

        it 'should create a new commodity transaction' do
          expect do
            post :create_purchase, id: ira, purchase: purchase_attributes
          end.to change(Transaction, :count).by(1)
        end

        it 'should create a new lot' do
          expect do
            post :create_purchase, id: ira, purchase: purchase_attributes
          end.to change(Lot, :count).by(1)
        end
      end
    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :index' do
        it 'should redirect to the user home page' do
          get :index, entity_id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe 'get :new' do
        it 'should redirect to the user home page' do
          get :new, entity_id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe 'post :create' do
        it 'should redirect to the user home page' do
          post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account, entity: entity)
          expect(response).to redirect_to home_path
        end

        it 'should not create a new account' do
          expect do
            post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account, entity: entity)
          end.not_to change(Account, :count)
        end
      end

      describe 'get :edit' do
        it 'should redirect to the user home page' do
          get :edit, id: checking
          expect(response).to redirect_to home_path
        end
      end

      describe 'put :update' do
        it 'should redirect to the user home page' do
          put :update, id: checking, account: { name: 'the new name' }
          expect(response).to redirect_to home_path
        end

        it 'should not update the account' do
          expect do
            put :update, id: checking, account: { name: 'the new name' }
            checking.reload
          end.not_to change(checking, :name)
        end
      end

      describe 'delete :destroy' do
        it 'should redirect to the user home page' do
          delete :destroy, id: checking
          expect(response).to redirect_to home_path
        end

        it 'should not delete the account' do
          expect do
            delete :destroy, id: checking
          end.not_to change(Account, :count)
        end
      end

      describe 'get :new_purchase' do
        it 'should redirect to the user home page' do
          get :new_purchase, id: ira
          expect(response).to redirect_to home_path
        end
      end

      describe 'post :create_purchase' do
        it 'should redirect to the user home page'
        it 'should not create a new commodity transaction'
        it 'should not create a new lot'
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
    
    describe 'get :new' do
      it 'should be redirect to the sign in page' do
        get :new, entity_id: entity
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :new, entity_id: entity, format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account)
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account), format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'get :show' do
      it 'should redirect to the sign in page' do
          get :show, id: checking
          response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :show, id: checking, format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'get :edit' do
      it 'should redirect to the sign in page' do
        get :edit, id: checking
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :edit, id: checking, format: :json
          response.response_code.should == 401
        end
      end
    end
    
    describe 'put :update' do
      it 'should redirect to the sign in page' do
        put :update, id: checking, account: { name: 'The new name' }
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          put :update, id: checking, account: { name: 'The new name' }, format: :json
          response.response_code.should == 401
        end
      end
    end
  
    describe 'delete :destroy' do
      it 'should redirect to sign in' do
        delete :destroy, id: checking
        response.should redirect_to new_user_session_path
      end
      
      it 'should not delete the specified account' do
        lambda do
          delete :destroy, id: checking
        end.should_not change(Account, :count)
      end
      
      context 'in json' do
        it 'should not delete the specified account' do
          lambda do
            delete :destroy, id: checking, format: :json
          end.should_not change(Account, :count)
        end
      end
    end

    describe 'get :new_purchase' do
      it 'should redirect to the sign in page' do
        get :new_purchase, id: ira
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'post :create_purchase' do
      it 'should redirect to the sign in page'
      it 'should not create a new commodity transaction'
      it 'should not create a new lot'
    end
  end
end
