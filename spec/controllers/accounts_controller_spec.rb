require 'spec_helper'

describe AccountsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:checking) { FactoryGirl.create(:account, entity: entity, name: 'checking') }
  let!(:cash) { FactoryGirl.create(:account, entity: entity, name: 'cash') }
  let (:ira) { FactoryGirl.create(:commodities_account, entity: entity, name: 'IRA') }
  let!(:kss) { FactoryGirl.create(:commodity, entity: entity, symbol: 'KSS') }
  let (:account_data) { fixture_file_upload('files/accounts.csv', 'text/csv') }
  let (:purchase_attributes) do
    {
      transaction_date: '2014-01-01',
      symbol: 'KSS',
      action: 'buy',
      shares: 100,
      value: 1_000
    }
  end

  shared_context 'savings' do
    let!(:savings) { FactoryGirl.create(:asset_account, entity: entity, name: 'savings') }
    let!(:car) { FactoryGirl.create(:asset_account, entity: entity, name: 'car', parent: savings) }
    let!(:reserve) { FactoryGirl.create(:asset_account, entity: entity, name: 'reserve', parent: savings) }
  end
  
  context 'for an authenticated user' do
    context 'that owns the entity' do
      before(:each) { sign_in entity.user }
      
      describe 'get :index' do
        it 'is successful' do
          get :index, entity_id: entity
          expect(response).to be_success
        end

        context 'in json' do
          it 'is successful' do
            get :index, entity_id: entity, format: :json
            expect(response).to be_success
          end
          
          it 'returns the list of accounts' do
            get :index, entity_id: entity, format: :json
            expect(response.body).to json_match [cash, checking]
          end

          context 'with "root_accounts_only" specified' do
            include_context 'savings'
            it 'returns only root accounts' do
              get :index, entity_id: entity, root_accounts_only: 1, format: :json
              expect(response.body).to json_match [cash, checking, savings]
            end
          end
        end
      end

      describe 'get :new' do
        it 'is successful' do
          get :new, entity_id: entity
          expect(response).to be_success
        end
      end
    
      describe 'post :create' do
        it 'redirects to the account list page' do
          post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account)
          expect(response).to redirect_to entity_accounts_path(entity)
        end
        
        context 'in json' do
          it 'creates a new account' do
            expect do
              post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account), format: :json
            end.to change(Account, :count).by(1)
          end
          
          it 'returns the new account' do
            attributes = FactoryGirl.attributes_for(:account)
            post :create, entity_id: entity, account: attributes, format: :json
            expect(response.body).to json_match attributes
          end
        end
      end

      describe 'get :show' do
        it 'is successful' do
          get :show, :id => checking
          expect(response).to be_success
        end
        
        context 'in json' do
          it 'returns the specified account' do
            get :show, id: checking, format: :json
            expect(response.body).to json_match checking
          end
        end     
      end
    
      describe 'get :edit' do
        it 'is successful' do
          get :edit, id: checking
          expect(response).to be_success
        end
      end
    
      describe 'put :update' do
        it 'redirects to the account list page' do
          put :update, id: checking, account: { name: 'The new name' }
          expect(response).to redirect_to entity_accounts_path(entity)
        end
        
        it 'updates the account' do
          expect do
            put :update, id: checking, account: { name: 'The new name' }
            checking.reload
          end.to change(checking, :name).from('checking').to('The new name')
        end
        
        context 'in json' do
          it 'updates the account' do
            expect do
              put :update, id: checking, account: { name: 'The new name' }, format: :json
              checking.reload
            end.to change(checking, :name).from('checking').to('The new name')
          end
        end
      end
  
      describe 'delete :destroy' do
        it 'redirects to the account list page' do
          delete :destroy, id: checking
          expect(response).to redirect_to entity_accounts_path(entity)
        end
        
        it 'deletes the specified account' do
          expect do
            delete :destroy, id: checking
          end.to change(Account, :count).by(-1)
        end
        
        context 'in json' do
          it 'is successful' do
            delete :destroy, id: checking, format: :json
            expect(response).to be_success
          end
          
          it 'deletes the specified account' do
            expect do
              delete :destroy, id: checking, format: :json
            end.to change(Account, :count).by(-1)
          end
        end
      end

      describe 'get :new_commodity_transaction' do
        it 'be successful' do
          get :new_commodity_transaction, id: ira
          expect(response).to be_success
        end
      end

      describe 'post :create_commodity_transaction' do
        it 'redirects to the holdings page' do
          post :create_commodity_transaction, id: ira, purchase: purchase_attributes
          expect(response).to redirect_to holdings_account_path(ira)
        end

        it 'creates a new commodity transaction' do
          expect do
            post :create_commodity_transaction, id: ira, purchase: purchase_attributes
          end.to change(Transaction, :count).by(1)
        end

        context 'for a purchase' do
          it 'creates a new lot' do
            expect do
              post :create_commodity_transaction, id: ira, purchase: purchase_attributes
            end.to change(Lot, :count).by(1)
          end

          context 'in json' do
            it 'is successful' do
              post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
              expect(response).to be_success
            end

            it 'returns the new transaction' do
              post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
              json = JSON.parse(response.body)
              expect(json).to include('transaction')
            end

            it 'returns the new lot' do
              post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
              json = JSON.parse(response.body)
              lots = json['lots']
              expect(lots).not_to be_nil
              expect(lots).to have(1).item
            end

            it 'creates a new commodity transaction' do
              expect do
                post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
              end.to change(Transaction, :count).by(1)
            end

            it 'creates a new lot' do
              expect do
                post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
              end.to change(Lot, :count).by(1)
            end

          end

          context 'for a sale' do
            let!(:ltg) { FactoryGirl.create(:income_account, name: 'Long-term capital gains', entity: entity) }
            let!(:stg) { FactoryGirl.create(:income_account, name: 'Short-term capital gains', entity: entity) }
            let!(:purchase1) do
              CommodityTransactionCreator.new(account: ira,
                                              action: CommodityTransactionCreator.buy,
                                              transaction_date: 2.days.ago,
                                              symbol: 'KSS',
                                              shares: 100,
                                              value: 1_000).create!
            end
            let!(:purchase2) do
              CommodityTransactionCreator.new(account: ira,
                                              action: CommodityTransactionCreator.buy,
                                              transaction_date: 1.day.ago,
                                              symbol: 'KSS',
                                              shares: 100,
                                              value: 1_200).create!
            end
            let (:sale_attributes) do
              {
                symbol: 'KSS',
                action: CommodityTransactionCreator.sell,
                shares: 150,
                value: 2_100
              }
            end

            it 'returns any affected lots for a sale' do
              post :create_commodity_transaction, id: ira, purchase: sale_attributes, format: :json
              json = JSON.parse(response.body)
              lots = json['lots']
              expect(lots).not_to be_nil
              expect(lots).to have(2).items
            end
          end
        end
      end

      describe 'get :holdings' do
        it 'is successful' do
          get :holdings, id: ira
          expect(response).to be_success
        end
      end

      describe 'get :children' do
        include_context 'savings'

        it 'is successful' do
          get :children, id: savings.id, format: :json
          expect(response).to be_success
        end

        it 'returns the children for the specified account' do
          get :children, id: savings.id, format: :json
          returned = JSON.parse(response.body).map{|a| a['name']}
          %w(car reserve).each{|a| expect(returned).to include(a)}
        end
      end
    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :index' do
        it 'redirects to the user home page' do
          get :index, entity_id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe 'get :new' do
        it 'redirects to the user home page' do
          get :new, entity_id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe 'post :create' do
        it 'redirects to the user home page' do
          post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account, entity: entity)
          expect(response).to redirect_to home_path
        end

        it 'does not create a new account' do
          expect do
            post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account, entity: entity)
          end.not_to change(Account, :count)
        end
      end

      describe 'get :edit' do
        it 'redirects to the user home page' do
          get :edit, id: checking
          expect(response).to redirect_to home_path
        end
      end

      describe 'put :update' do
        it 'redirects to the user home page' do
          put :update, id: checking, account: { name: 'the new name' }
          expect(response).to redirect_to home_path
        end

        it 'does not update the account' do
          expect do
            put :update, id: checking, account: { name: 'the new name' }
            checking.reload
          end.not_to change(checking, :name)
        end
      end

      describe 'delete :destroy' do
        it 'redirects to the user home page' do
          delete :destroy, id: checking
          expect(response).to redirect_to home_path
        end

        it 'does not delete the account' do
          expect do
            delete :destroy, id: checking
          end.not_to change(Account, :count)
        end
      end

      describe 'get :new_commodity_transaction' do
        it 'redirects to the user home page' do
          get :new_commodity_transaction, id: ira
          expect(response).to redirect_to home_path
        end
      end

      describe 'post :create_commodity_transaction' do
        it 'redirects to the user home page' do
          post :create_commodity_transaction, id: ira, purchase: purchase_attributes
          expect(response).to redirect_to home_path
        end

        it 'does not create a new commodity transaction' do
          expect do
            post :create_commodity_transaction, id: ira, purchase: purchase_attributes
          end.not_to change(Transaction, :count)
        end

        it 'does not create a new lot' do
          expect do
            post :create_commodity_transaction, id: ira, purchase: purchase_attributes
          end.not_to change(Lot, :count)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not create a new commodity transaction' do
            expect do
              post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
            end.not_to change(Transaction, :count)
          end

          it 'does not create a new lot' do
            expect do
              post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
            end.not_to change(Lot, :count)
          end
        end
      end

      describe 'get :holdings' do
        it 'redirects to the user home page' do
          get :holdings, id: ira
          expect(response).to redirect_to home_path
        end
      end

      describe 'get :children' do
        it 'returns "resource not found"' do
          get :children, id: checking, format: :json
          expect(response.response_code).to eq(404)
        end

        it 'does not return any account data' do
          get :children, id: checking, format: :json
          expect(response.body).to eq('[]')
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
      it 'is redirect to the sign in page' do
        get :new, entity_id: entity
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          get :new, entity_id: entity, format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end
    
    describe 'post :create' do
      it 'redirects to the sign in page' do
        post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account)
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          post :create, entity_id: entity, account: FactoryGirl.attributes_for(:account), format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end
    
    describe 'get :show' do
      it 'redirects to the sign in page' do
          get :show, id: checking
          expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          get :show, id: checking, format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end
    
    describe 'get :edit' do
      it 'redirects to the sign in page' do
        get :edit, id: checking
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          get :edit, id: checking, format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end
    
    describe 'put :update' do
      it 'redirects to the sign in page' do
        put :update, id: checking, account: { name: 'The new name' }
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          put :update, id: checking, account: { name: 'The new name' }, format: :json
          expect(response.response_code).to eq(401)
        end
      end
    end
  
    describe 'delete :destroy' do
      it 'redirects to sign in' do
        delete :destroy, id: checking
        expect(response).to redirect_to new_user_session_path
      end
      
      it 'does not delete the specified account' do
        expect do
          delete :destroy, id: checking
        end.to_not change(Account, :count)
      end
      
      context 'in json' do
        it 'does not delete the specified account' do
          expect do
            delete :destroy, id: checking, format: :json
          end.to_not change(Account, :count)
        end
      end
    end

    describe 'get :new_commodity_transaction' do
      it 'redirects to the sign in page' do
        get :new_commodity_transaction, id: ira
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'post :create_commodity_transaction' do
      it 'redirects to the sign in page' do
        post :create_commodity_transaction, id: ira, purchase: purchase_attributes
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create a new commodity transaction' do
        expect do
          post :create_commodity_transaction, id: ira, purchase: purchase_attributes
        end.not_to change(Transaction, :count)
      end

      it 'does not create a new lot' do
        expect do
          post :create_commodity_transaction, id: ira, purchase: purchase_attributes
        end.not_to change(Lot, :count)
      end

      context 'in json' do
        it 'returns "access denied"' do
          post :create_commodity_transaction, id:ira, purchase: purchase_attributes, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not create a new commodity transaction' do
          expect do
            post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
          end.not_to change(Transaction, :count)
        end

        it 'does not create a new lot' do
          expect do
            post :create_commodity_transaction, id: ira, purchase: purchase_attributes, format: :json
          end.not_to change(Lot, :count)
        end
      end
    end

    describe 'get :holdings' do
      it 'redirects to the sign in page' do
        get :holdings, id: ira
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'get :children' do
      it 'returns "access denied"' do
        get :children, id: checking, format: :json
        expect(response.response_code).to eq(401)
      end

      it 'does not return any account data' do
        get :children, id: checking, format: :json
        returned = JSON.parse(response.body)
        expect(returned).to have(1).item
        expect(returned).to have_key("error")
      end
    end
  end
end
