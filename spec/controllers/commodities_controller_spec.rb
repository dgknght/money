require 'spec_helper'

describe CommoditiesController do

  let (:entity) { FactoryGirl.create(:entity) }
  let!(:commodity) { FactoryGirl.create(:commodity, entity: entity, symbol: 'AAPL') }
  let (:attributes) do
    {
      name: 'Knight Software Services',
      symbol: 'KSS', 
      market: Commodity.nyse
    }
  end
  shared_context 'split' do
    let (:split_attributes) do
      {
        numerator: 2,
        denominator: 1
      }
    end
    let (:ira) do
      FactoryGirl.create(:asset_account, content_type: Account.commodities_content,
                                         entity: entity)
    end
    let (:opening_balances) { FactoryGirl.create(:equity_account, entity: entity) }
    let!(:opening_trans) do
      FactoryGirl.create(:transaction, transaction_date: Chronic.parse('2015-01-01'),
                                       description: 'Opening balance',
                                       amount: 10_000,
                                       debit_account: ira,
                                       credit_account: opening_balances)
    end
    let!(:purchase_trans) do
      CommodityTransactionCreator.new(trade_date: Chronic.parse('2015-01-02'),
                                                  account: ira,
                                                  action: 'buy',
                                                  symbol: 'AAPL',
                                                  shares: 100,
                                                  value: 2_000).create!
    end
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

          it 'returns the list of commodities' do
            get :index, entity_id: entity, format: :json
            expect(response.body).to json_match([commodity])
          end
        end
      end

      describe 'get :show' do
        context 'in json' do
          it 'is successful' do
            get :show, id: commodity, format: :json
            expect(response).to be_success
          end

          it 'returns the specified commodity' do
            get :show, id: commodity, format: :json
            expect(response.body).to json_match(commodity)
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
        it 'redirects to the commodity list page' do
          post :create, entity_id: entity, commodity: attributes
          expect(response).to redirect_to(entity_commodities_path(entity))
        end

        it 'creates the new commodity' do
          expect do
            post :create, entity_id: entity, commodity: attributes
          end.to change(Commodity, :count).by(1)
        end

        context 'in json' do
          it 'is successful' do
            post :create, entity_id: entity, commodity: attributes, format: :json
            expect(response).to be_success
          end

          it 'creates the new commodity' do
            expect do
              post :create, entity_id: entity, commodity: attributes, format: :json
            end.to change(Commodity, :count).by(1)
          end
        end
      end

      describe 'get :edit' do
        it 'is successful' do
          get :edit, id: commodity
          expect(response).to be_success
        end
      end

      describe 'put :update' do
        it 'redirects to the commodity list page' do
          put :update, id: commodity, commodity: attributes
          expect(response).to redirect_to(entity_commodities_path(entity))
        end

        it 'updates the commodity' do
          expect do
            put :update, id: commodity, commodity: attributes
            commodity.reload
          end.to change(commodity, :name).to('Knight Software Services')
        end

        context 'in json' do
          it 'is successful' do
            put :update, id: commodity, commodity: attributes, format: :json
            expect(response).to be_success
          end

          it 'updates the commodity' do
            expect do
              put :update, id: commodity, commodity: attributes, format: :json
              commodity.reload
            end.to change(commodity, :name).to('Knight Software Services')
          end
        end
      end

      describe 'delete :destroy' do
        it 'redirects to the commodity list page' do
          delete :destroy, id: commodity
          expect(response).to redirect_to(entity_commodities_path(entity))
        end

        it 'deletes the commodity' do
          expect do
            delete :destroy, id: commodity
          end.to change(Commodity, :count).by(-1)
        end

        context 'in json' do
          it 'is successful' do
            delete :destroy, id: commodity, format: :json
            expect(response).to be_success
          end

          it 'deletes the commodity' do
            expect do
              delete :destroy, id: commodity, format: :json
            end.to change(Commodity, :count).by(-1)
          end
        end
      end

      describe 'get :new_split' do
        include_context 'split'

        it 'is successful' do
          get :new_split, id: commodity
          expect(response).to be_success
        end
      end

      describe 'put :split' do
        include_context 'split'

        it 'redirects to the lot index page' do
          put :split, id: commodity, split: split_attributes, account_id: ira.id
          expect(response).to redirect_to(account_lots_path(ira))
        end

        it 'records the stock split' do
          lots = commodity.lots.to_a
          expect do
            put :split, id: commodity, split: split_attributes, account_id: ira.id
            lots.each{|l| l.reload}
          end.to change(lots.first, :shares_owned).from(BigDecimal.new(100)).to(BigDecimal.new(200))
        end
      end
    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :index' do
        it 'redirects to the user home page' do
          get :index, entity_id: entity
          expect(response).to redirect_to(home_path)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            get :index, entity_id: entity, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not return any data' do
            get :index, entity_id: entity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :show' do
        it 'redirects to the user home page' do
          get :show, id: commodity
          expect(response).to redirect_to(home_path)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            get :show, id: commodity, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not return any data' do
            get :show, id: commodity, format: :json
            expect(response.body).to eq([].to_json)
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
        it 'redirects to the user home page' do
          post :create, entity_id: entity, commodity: attributes
          expect(response).to redirect_to(home_path)
        end

        it 'does not create the new commodity' do
          expect do
            post :create, entity_id: entity, commodity: attributes
          end.not_to change(Commodity, :count)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            post :create, entity_id: entity, commodity: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not create the new commodity' do
            expect do
              post :create, entity_id: entity, commodity: attributes, format: :json
            end.not_to change(Commodity, :count)
          end

          it 'does not return any data' do
            post :create, entity_id: entity, commodity: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :edit' do
        it 'redirects to the user home page' do
          get :edit, id: commodity
          expect(response).to redirect_to(home_path)
        end
      end

      describe 'put :update' do
        it 'redirects to the user home page' do
          put :update, id: commodity, commodity: attributes
          expect(response).to redirect_to(home_path)
        end

        it 'does not update the commodity' do
          expect do
            put :update, id: commodity, commodity: attributes
            commodity.reload
          end.not_to change(commodity, :name)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            put :update, id: commodity, commodity: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not update the commodity' do
            expect do
              put :update, id: commodity, commodity: attributes, format: :json
              commodity.reload
            end.not_to change(commodity, :name)
          end

          it 'does not return any data' do
            put :update, id: commodity, commodity: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'delete :destroy' do
        it 'redirects to the user home page' do
          delete :destroy, id: commodity
          expect(response).to redirect_to(home_path)
        end

        it 'does not delete the commodity' do
          expect do
            delete :destroy, id: commodity
          end.not_to change(Commodity, :count)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            delete :destroy, id: commodity, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not delete the commodity' do
            expect do
              delete :destroy, id: commodity, format: :json
            end.not_to change(Commodity, :count)
          end

          it 'does not return any data' do
            delete :destroy, id: commodity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :new_split' do
        it 'redirects to the user home page' do
          get :new_split, id: commodity
          expect(response).to redirect_to home_path
        end
      end

      describe 'put :split' do
        include_context 'split'

        it 'redirects to the user home page' do
          put :split, id: commodity, split: split_attributes, account_id: ira.id
          expect(response).to redirect_to home_path
        end

        it 'does not record the stock split' do
          lots = commodity.lots.to_a
          expect do
            put :split, id: commodity, split: split_attributes, account_id: ira.id
            lots.each {|l| l.reload}
          end.not_to change(lots.first, :shares_owned)
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the sign in page' do
        get :index, entity_id: entity
        expect(response).to redirect_to(new_user_session_path)
      end

      context 'in json' do
        it 'returns "access denied"' do
          get :index, entity_id: entity, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'returns an error' do
          get :index, entity_id: entity, format: :json
          data = JSON.parse(response.body)
          expect(data).to have_only('error')
        end
      end
    end

    describe 'get :show' do
      it 'redirects to the sign in page' do
        get :show, id: commodity
        expect(response).to redirect_to(new_user_session_path)
      end

      context 'in json' do
        it 'returns "access denied"' do
          get :show, id: commodity, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'returns an error' do
          get :show, id: commodity, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
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
        post :create, entity_id: entity, commodity: attributes
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not create the new commodity' do
        expect do
          post :create, entity_id: entity, commodity: attributes
        end.not_to change(Commodity, :count)
      end

      context 'in json' do
        it 'returns "access denied"' do
          post :create, entity_id: entity, commodity: attributes, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not create the new commodity' do
          expect do
            post :create, entity_id: entity, commodity: attributes, format: :json
          end.not_to change(Commodity, :count)
        end

        it 'returns an error' do
          post :create, entity_id: entity, commodity: attributes, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'get :edit' do
      it 'redirects to the sign in page' do
        get :edit, id: commodity
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'put :update' do
      it 'redirects to the sign in page' do
        put :update, id: commodity, commodity: attributes
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not update the commodity' do
        expect do
          put :update, id: commodity, commodity: attributes
          commodity.reload
        end.not_to change(commodity, :name)
      end

      context 'in json' do
        it 'returns "access denied"' do
          put :update, id: commodity, commodity: attributes, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not update the commodity' do
          expect do
            put :update, id: commodity, commodity: attributes, format: :json
            commodity.reload
          end.not_to change(commodity, :name)
        end

        it 'returns an error' do
          put :update, id: commodity, commodity: attributes, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'delete :destroy' do
      it 'redirects to the sign in page' do
        delete :destroy, id: commodity
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not delete the commodity' do
        expect do
          delete :destroy, id: commodity
        end.not_to change(Commodity, :count)
      end

      context 'in json' do
        it 'returns "access denied"' do
          delete :destroy, id: commodity, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not delete the commodity' do
          expect do
            delete :destroy, id: commodity, format: :json
          end.not_to change(Commodity, :count)
        end

        it 'returns an error' do
          delete :destroy, id: commodity, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'get :new_split' do
      it 'redirects to the sign in page' do
        get :new_split, id: commodity
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'put :split' do
      include_context 'split'

      it 'redirects to the sign in page' do
        put :split, id: commodity, split: split_attributes, account_id: ira.id
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not record the stock split' do
        lots = commodity.lots.to_a
        expect do
          put :split, id: commodity, split: split_attributes, account_id: ira.id
          lots.each{|l| l.reload}
        end.not_to change(lots.first, :shares_owned)
      end
    end
  end
end
