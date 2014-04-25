require 'spec_helper'

describe PricesController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:commodity) { FactoryGirl.create(:commodity, entity: entity) }
  let!(:price) { FactoryGirl.create(:price, commodity: commodity) }
  let (:attributes) do
    {
      trade_date: Date.today.iso8601,
      price: '12.3456'
    }
  end

  context 'for an authenticated user' do
    context 'that owns the entity' do

      before(:each) { sign_in entity.user }

      describe 'get :index' do
        it 'should be successful' do
          get :index, commodity_id: commodity
          expect(response).to be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :index, commodity_id: commodity, format: :json
            expect(response).to be_success
          end

          it 'should return the list of commodity prices' do
            get :index, commodity_id: commodity, format: :json
            expect(response.body).to eq([price].to_json)
          end
        end
      end

      describe 'get :show' do
        it 'should be successful' do
          get :show, id: price
          expect(response).to be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :show, id: price, format: :json
            expect(response).to be_success
          end

          it 'should return the specified commodity price' do
            get :show, id: price, format: :json
            expect(response.body).to eq(price.to_json)
          end
        end
      end

      describe 'get :new' do
        it 'should be successful' do
          get :new, commodity_id: commodity
          expect(response).to be_success
        end
      end

      describe 'post :create' do
        it 'should redirect to the commodity price index page' do
          post :create, commodity_id: commodity, price: attributes
          expect(response).to redirect_to commodity_prices_path(commodity)
        end

        it 'should create a new commodity price' do
          expect do
            post :create, commodity_id: commodity, price: attributes
          end.to change(commodity.prices, :count).by(1)
        end

        context 'in json' do
          it 'should be successful' do
            post :create, commodity_id: commodity, price: attributes, format: :json
            expect(response).to be_success
          end

          it 'should create a new commodity price' do
            expect do
              post :create, commodity_id: commodity, price: attributes, format: :json
            end.to change(commodity.prices, :count).by(1)
          end

          it 'should return the new commodity price' do
            post :create, commodity_id: commodity, price: attributes, format: :json

            puts "response.body=#{response.body}"

            returned = JSON.parse(response.body)
            attributes.each do |key, value|
              expect(returned[key.to_s]).to eq(value)
            end
          end
        end
      end

      describe 'get :edit' do
        it 'should be successful' do
          get :edit, id: price
          expect(response).to be_success
        end
      end

      describe 'put :update' do
        it 'should redirect to the commodity prices index page' do
          put :update, id: price, price: attributes
          expect(response).to redirect_to commodity_prices_path(commodity)
        end

        it' should update the specified commodity' do
          expect do
            put :update, id: price, price: attributes
            price.reload
          end.to change(price, :price).to(12.3456)
        end

        context 'in json' do
          it 'should be successful' do
            put :update, id: price, price: attributes, format: :json
            expect(response).to be_success
          end

          it 'should update the specified commodity' do
            expect do
              put :update, id: price, price: attributes, format: :json
              price.reload
            end.to change(price, :price).to(12.3456)
          end
        end
      end

      describe 'delete :destroy' do
        it 'should redirect to the commodity prices index page' do
          delete :destroy, id: price
          expect(response).to redirect_to commodity_prices_path(commodity)
        end

        it 'should delete the specified commodity' do
          expect do
            delete :destroy, id: price
          end.to change(Price, :count).by(-1)
        end

        context 'in json' do
          it 'should be successful' do
            delete :destroy, id: price, format: :json
            expect(response).to be_success
          end

          it 'should delete the specified commodity' do
            expect do
              delete :destroy, id: price, format: :json
            end.to change(Price, :count).by(-1)
          end
        end
      end
    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :index' do
        it 'should redirect to the user home page' do
          get :index, commodity_id: commodity
          expect(response).to redirect_to home_path
        end

        context 'in json' do
          it 'should return "resource not found"' do
            get :index, commodity_id: commodity, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not return any data' do
            get :index, commodity_id: commodity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :show' do
        it 'should redirect to the user home page' do
          get :show, id: price
          expect(response).to redirect_to home_path
        end

        context 'in json' do
          it 'should return "resource not found"' do
            get :show, id: price, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not return any data' do
            get :show, id: price, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :new' do
        it 'should redirect to the user home page' do
          get :new, commodity_id: commodity
          expect(response).to redirect_to home_path
        end
      end

      describe 'post :create' do
        it 'should redirect to the user home page' do
          post :create, commodity_id: commodity, price: attributes
          expect(response).to redirect_to home_path
        end

        it 'should not create a new commodity price' do
          expect do
            post :create, commodity_id: commodity, price: attributes
          end.not_to change(Price, :count)
        end

        context 'in json' do
          it 'should return "resource not found"' do
            post :create, commodity_id: commodity, price: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not create a new commodity price' do
            expect do
              post :create, commodity_id: commodity, price: attributes, format: :json
            end.not_to change(Price, :count)
          end

          it 'should not return any data' do
            post :create, commodity_id: commodity, price: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :edit' do
        it 'should redirect to the user home page' do
          get :edit, id: price
          expect(response).to redirect_to home_path
        end
      end

      describe 'put :update' do
        it 'should redirect to the user home page' do
          put :update, id: price, price: attributes
          expect(response).to redirect_to home_path
        end

        it' should not update the specified commodity' do
          expect do
            put :update, id: price, price: attributes
            price.reload
          end.not_to change(price, :updated_at)
        end

        context 'in json' do
          it 'should return "resource not found"' do
            put :update, id: price, price: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not update the specified commodity' do
            expect do
              put :update, id: price, price: attributes, format: :json
              price.reload
            end.not_to change(price, :updated_at)
          end

          it 'should not return any data' do
            put :update, id: price, price: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'delete :destroy' do
        it 'should redirect to the user home page'
        it 'should not delete the specified commodity'

        context 'in json' do
          it 'should return "resource not found"'
          it 'should not delete the specified commodity'
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index, commodity_id: commodity
        expect(response).to redirect_to(new_user_session_path)
      end

      context 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
      end
    end

    describe 'get :show' do
      it 'should redirect to the sign in page'

      context 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
      end
    end

    describe 'get :new' do
      it 'should redirect to the sign in page'
    end

    describe 'post :create' do
      it 'should redirect to the sign in page'
      it 'should not create a new commodity price'

      context 'in json' do
        it 'should return "access denied"'
        it 'should not create a new commodity price'
        it 'should not return any data'
      end
    end

    describe 'get :edit' do
      it 'should redirect to the sign in page'
    end

    describe 'put :update' do
      it 'should redirect to the sign in page'
      it' should not update the specified commodity'

      context 'in json' do
        it 'should return "access denied"'
        it 'should not update the specified commodity'
      end
    end

    describe 'delete :destroy' do
      it 'should redirect to the sign in page'
      it 'should not delete the specified commodity'

      context 'in json' do
        it 'should return "access denied"'
        it 'should not delete the specified commodity'
      end
    end
  end
end
