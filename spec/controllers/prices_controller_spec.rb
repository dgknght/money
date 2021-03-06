require 'spec_helper'

describe PricesController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:commodity) { FactoryGirl.create(:commodity, entity: entity) }
  let!(:price) { FactoryGirl.create(:price, commodity: commodity, trade_date: '2014-02-27') }
  let (:attributes) do
    {
      trade_date: '2014-02-28',
      price: 12.3456
    }
  end

  context 'for an authenticated user' do
    context 'that owns the entity' do

      before(:each) { sign_in entity.user }

      describe 'get :index' do
        it 'is successful' do
          get :index, commodity_id: commodity
          expect(response).to be_success
        end

        context 'in json' do
          let!(:price_2) { FactoryGirl.create(:price, commodity: commodity, trade_date: '2014-03-01') }
          it 'is successful' do
            get :index, commodity_id: commodity, format: :json
            expect(response).to be_success
          end

          it 'returns the list of prices' do
            get :index, commodity_id: commodity, format: :json
            expect(response.body).to json_match([price_2, price])
          end
        end
      end

      describe 'get :show' do
        it 'is successful' do
          get :show, id: price
          expect(response).to be_success
        end

        context 'in json' do
          it 'is successful' do
            get :show, id: price, format: :json
            expect(response).to be_success
          end

          it 'returns the specified price' do
            get :show, id: price, format: :json
            expect(response.body).to json_match(price)
          end
        end
      end

      describe 'get :new' do
        it 'is successful' do
          get :new, commodity_id: commodity
          expect(response).to be_success
        end
      end

      describe 'post :create' do
        it 'redirects to the price index page' do
          post :create, commodity_id: commodity, price: attributes
          expect(response).to redirect_to commodity_prices_path(commodity)
        end

        it 'creates a new price' do
          expect do
            post :create, commodity_id: commodity, price: attributes
          end.to change(commodity.prices, :count).by(1)
        end

        context 'in json' do
          it 'is successful' do
            post :create, commodity_id: commodity, price: attributes, format: :json
            expect(response).to be_success
          end

          it 'creates a new price' do
            expect do
              post :create, commodity_id: commodity, price: attributes, format: :json
            end.to change(commodity.prices, :count).by(1)
          end

          it 'returns the new price' do
            post :create, commodity_id: commodity, price: attributes, format: :json
            expect(response.body).to json_match attributes
          end
        end
      end

      describe 'get :edit' do
        it 'is successful' do
          get :edit, id: price
          expect(response).to be_success
        end
      end

      describe 'put :update' do
        it 'redirects to the prices index page' do
          put :update, id: price, price: attributes
          expect(response).to redirect_to commodity_prices_path(commodity)
        end

        it 'updates the specified price' do
          expect do
            put :update, id: price, price: attributes
            price.reload
          end.to change(price, :price).to(12.3456)
        end

        context 'in json' do
          it 'is successful' do
            put :update, id: price, price: attributes, format: :json
            expect(response).to be_success
          end

          it 'updates the specified price' do
            expect do
              put :update, id: price, price: attributes, format: :json
              price.reload
            end.to change(price, :price).to(12.3456)
          end
        end
      end

      describe 'delete :destroy' do
        it 'redirects to the prices index page' do
          delete :destroy, id: price
          expect(response).to redirect_to commodity_prices_path(commodity)
        end

        it 'deletes the specified price' do
          expect do
            delete :destroy, id: price
          end.to change(Price, :count).by(-1)
        end

        context 'in json' do
          it 'is successful' do
            delete :destroy, id: price, format: :json
            expect(response).to be_success
          end

          it 'deletes the specified price' do
            expect do
              delete :destroy, id: price, format: :json
            end.to change(Price, :count).by(-1)
          end
        end
      end

      describe 'patch :download' do
        it 'redirect to the commodity list page for the entity' do
          patch :download, entity_id: entity
          expect(response).to redirect_to entity_commodities_path(entity)
        end

        it 'initiates a price download' do
          allow(StockPrices::PriceDownloader).to receive(:download)
          patch :download, entity_id: entity
        end
      end
    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :index' do
        it 'redirects to the user home page' do
          get :index, commodity_id: commodity
          expect(response).to redirect_to home_path
        end

        context 'in json' do
          it 'returns "resource not found"' do
            get :index, commodity_id: commodity, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not return any data' do
            get :index, commodity_id: commodity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :show' do
        it 'redirects to the user home page' do
          get :show, id: price
          expect(response).to redirect_to home_path
        end

        context 'in json' do
          it 'returns "resource not found"' do
            get :show, id: price, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not return any data' do
            get :show, id: price, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :new' do
        it 'redirects to the user home page' do
          get :new, commodity_id: commodity
          expect(response).to redirect_to home_path
        end
      end

      describe 'post :create' do
        it 'redirects to the user home page' do
          post :create, commodity_id: commodity, price: attributes
          expect(response).to redirect_to home_path
        end

        it 'does not create a new price' do
          expect do
            post :create, commodity_id: commodity, price: attributes
          end.not_to change(Price, :count)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            post :create, commodity_id: commodity, price: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not create a new price' do
            expect do
              post :create, commodity_id: commodity, price: attributes, format: :json
            end.not_to change(Price, :count)
          end

          it 'does not return any data' do
            post :create, commodity_id: commodity, price: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :edit' do
        it 'redirects to the user home page' do
          get :edit, id: price
          expect(response).to redirect_to home_path
        end
      end

      describe 'put :update' do
        it 'redirects to the user home page' do
          put :update, id: price, price: attributes
          expect(response).to redirect_to home_path
        end

        it 'does not update the specified price' do
          expect do
            put :update, id: price, price: attributes
            price.reload
          end.not_to change(price, :price)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            put :update, id: price, price: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not update the specified price' do
            expect do
              put :update, id: price, price: attributes, format: :json
              price.reload
            end.not_to change(price, :price)
          end

          it 'does not return any data' do
            put :update, id: price, price: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'delete :destroy' do
        it 'redirects to the user home page' do
          delete :destroy, id: price
          expect(response).to redirect_to home_path
        end

        it 'does not delete the specified price' do
          expect do
            delete :destroy, id: price
          end.not_to change(Price, :count)
        end

        context 'in json' do
          it 'returns "resource not found"' do
            delete :destroy, id: price, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not delete the specified price' do
            expect do
              delete :destroy, id: price, format: :json
            end.not_to change(Price, :count)
          end
        end
      end

      describe 'patch :download' do
        it 'redirects to the user home page' do
          patch :download, entity_id: entity
          expect(response).to redirect_to(home_path)
        end

        it 'does not initiate a price download' do
          allow(StockPrices::PriceDownloader).to receive(:download).never
          patch :download, entity_id: entity
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the sign in page' do
        get :index, commodity_id: commodity
        expect(response).to redirect_to(new_user_session_path)
      end

      context 'in json' do
        it 'returns "access denied"' do
          get :index, commodity_id: commodity, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not return any data' do
          get :index, commodity_id: commodity, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'get :show' do
      it 'redirects to the sign in page' do
        get :show, id: price
        expect(response).to redirect_to new_user_session_path
      end

      context 'in json' do
        it 'returns "access denied"' do
          get :show, id: price, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not return any data' do
          get :show, id: price, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'get :new' do
      it 'redirects to the sign in page' do
        get :new, commodity_id: commodity
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'post :create' do
      it 'redirects to the sign in page' do
        post :create, commodity_id: commodity
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create a new price' do
        expect do
          post :create, commodity_id: commodity
        end.not_to change(Price, :count)
      end

      context 'in json' do
        it 'returns "access denied"' do
          post :create, commodity_id: commodity, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not create a new price' do
          expect do
            post :create, commodity_id: commodity, format: :json
          end.not_to change(Price, :count)
        end

        it 'does not return any data' do
          post :create, commodity_id: commodity, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'get :edit' do
      it 'redirects to the sign in page' do
        get :edit, id: price
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'put :update' do
      it 'redirects to the sign in page' do
        put :update, id: price, price: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not update the specified price' do
        expect do
          put :update, id: price, price: attributes
          price.reload
        end.not_to change(price, :price)
      end

      context 'in json' do
        it 'returns "access denied"' do
          put :update, id: price, price: attributes, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not update the specified price' do
          expect do
            put :update, id: price, price: attributes, format: :json
            price.reload
          end.not_to change(price, :price)
        end
      end
    end

    describe 'delete :destroy' do
      it 'redirects to the sign in page' do
        delete :destroy, id: price
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not delete the specified price' do
        expect do
          delete :destroy, id: price
        end.not_to change(Price, :count)
      end

      context 'in json' do
        it 'returns "access denied"' do
          delete :destroy, id: price, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'does not delete the specified price' do
          expect do
            delete :destroy, id: price, format: :json
          end.not_to change(Price, :count)
        end
      end
    end

    describe 'patch :download' do
      it 'redirects to the sign in page' do
        patch :download, entity_id: entity
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'does not initiate a price download' do
        allow(StockPrices::PriceDownloader).to receive(:download).never
        patch :download, entity_id: entity
      end
    end
  end
end
