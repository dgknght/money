require 'spec_helper'

describe CommoditiesController do

  let (:entity) { FactoryGirl.create(:entity) }
  let!(:commodity) { FactoryGirl.create(:commodity, entity: entity) }
  let (:attributes) do
    {
      name: 'Knight Software Services',
      symbol: 'KSS', 
      market: Commodity.nyse
    }
  end

  context 'for an authenticated user' do
    context 'that owns the entity' do
      before(:each) { sign_in entity.user }

      describe 'get :index' do
        it 'should be successful' do
          get :index, entity_id: entity
          expect(response).to be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :index, entity_id: entity, format: :json
            expect(response).to be_success
          end

          it 'should return the list of commodities' do
            get :index, entity_id: entity, format: :json
            expect(response.body).to eq([commodity].to_json)
          end
        end
      end

      describe 'get :show' do
        it 'should be successful' do
          get :show, id: commodity
          expect(response).to be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :show, id: commodity, format: :json
            expect(response).to be_success
          end

          it 'should return the specified commodity' do
            get :show, id: commodity, format: :json
            expect(response.body).to eq(commodity.to_json)
          end
        end
      end

      describe 'get :new' do
        it 'should be successful' do
          get :new, entity_id: entity
          expect(response).to be_success
        end
      end

      describe 'post :create' do
        it 'should redirect to the commodity list page' do
          post :create, entity_id: entity, commodity: attributes
          expect(response).to redirect_to(entity_commodities_path(entity))
        end

        it 'should create the new commodity' do
          expect do
            post :create, entity_id: entity, commodity: attributes
          end.to change(Commodity, :count).by(1)
        end

        context 'in json' do
          it 'should be successful' do
            post :create, entity_id: entity, commodity: attributes, format: :json
            expect(response).to be_success
          end

          it 'should create the new commodity' do
            expect do
              post :create, entity_id: entity, commodity: attributes, format: :json
            end.to change(Commodity, :count).by(1)
          end
        end
      end

      describe 'get :edit' do
        it 'should be successful' do
          get :edit, id: commodity
          expect(response).to be_success
        end
      end

      describe 'put :update' do
        it 'should redirect to the commodity list page' do
          put :update, id: commodity, commodity: attributes
          expect(response).to redirect_to(entity_commodities_path(entity))
        end

        it 'should update the commodity' do
          expect do
            put :update, id: commodity, commodity: attributes
            commodity.reload
          end.to change(commodity, :name).to('Knight Software Services')
        end

        context 'in json' do
          it 'should be successful' do
            put :update, id: commodity, commodity: attributes, format: :json
            expect(response).to be_success
          end

          it 'should update the commodity' do
            expect do
              put :update, id: commodity, commodity: attributes, format: :json
              commodity.reload
            end.to change(commodity, :name).to('Knight Software Services')
          end
        end
      end

      describe 'delete :destroy' do
        it 'should redirect to the commodity list page' do
          delete :destroy, id: commodity
          expect(response).to redirect_to(entity_commodities_path(entity))
        end

        it 'should delete the commodity' do
          expect do
            delete :destroy, id: commodity
          end.to change(Commodity, :count).by(-1)
        end

        context 'in json' do
          it 'should be successful' do
            delete :destroy, id: commodity, format: :json
            expect(response).to be_success
          end

          it 'should delete the commodity' do
            expect do
              delete :destroy, id: commodity, format: :json
            end.to change(Commodity, :count).by(-1)
          end
        end
      end
    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :index' do
        it 'should redirect to the user home page' do
          get :index, entity_id: entity
          expect(response).to redirect_to(home_path)
        end

        context 'in json' do
          it 'should return "resource not found"' do
            get :index, entity_id: entity, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not return any data' do
            get :index, entity_id: entity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :show' do
        it 'should redirect to the user home page' do
          get :show, id: commodity
          expect(response).to redirect_to(home_path)
        end

        context 'in json' do
          it 'should return "resource not found"' do
            get :show, id: commodity, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not return any data' do
            get :show, id: commodity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :new' do
        it 'should redirect to the user home page' do
          get :new, entity_id: entity
          expect(response).to redirect_to(home_path)
        end
      end

      describe 'post :create' do
        it 'should redirect to the user home page' do
          post :create, entity_id: entity, commodity: attributes
          expect(response).to redirect_to(home_path)
        end

        it 'should not create the new commodity' do
          expect do
            post :create, entity_id: entity, commodity: attributes
          end.not_to change(Commodity, :count)
        end

        context 'in json' do
          it 'should return "resource not found"' do
            post :create, entity_id: entity, commodity: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not create the new commodity' do
            expect do
              post :create, entity_id: entity, commodity: attributes, format: :json
            end.not_to change(Commodity, :count)
          end

          it 'should not return any data' do
            post :create, entity_id: entity, commodity: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'get :edit' do
        it 'should redirect to the user home page' do
          get :edit, id: commodity
          expect(response).to redirect_to(home_path)
        end
      end

      describe 'put :update' do
        it 'should redirect to the user home page' do
          put :update, id: commodity, commodity: attributes
          expect(response).to redirect_to(home_path)
        end

        it 'should not update the commodity' do
          expect do
            put :update, id: commodity, commodity: attributes
            commodity.reload
          end.not_to change(commodity, :name)
        end

        context 'in json' do
          it 'should return "resource not found"' do
            put :update, id: commodity, commodity: attributes, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not update the commodity' do
            expect do
              put :update, id: commodity, commodity: attributes, format: :json
              commodity.reload
            end.not_to change(commodity, :name)
          end

          it 'should not return any data' do
            put :update, id: commodity, commodity: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe 'delete :destroy' do
        it 'should redirect to the user home page' do
          delete :destroy, id: commodity
          expect(response).to redirect_to(home_path)
        end

        it 'should not delete the commodity' do
          expect do
            delete :destroy, id: commodity
          end.not_to change(Commodity, :count)
        end

        context 'in json' do
          it 'should return "resource not found"' do
            delete :destroy, id: commodity, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'should not delete the commodity' do
            expect do
              delete :destroy, id: commodity, format: :json
            end.not_to change(Commodity, :count)
          end

          it 'should not return any data' do
            delete :destroy, id: commodity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index, entity_id: entity
        expect(response).to redirect_to(new_user_session_path)
      end

      context 'in json' do
        it 'should return "access denied"' do
          get :index, entity_id: entity, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'should return an error' do
          get :index, entity_id: entity, format: :json
          data = JSON.parse(response.body)
          expect(data).to have_only('error')
        end
      end
    end

    describe 'get :show' do
      it 'should redirect to the sign in page' do
        get :show, id: commodity
        expect(response).to redirect_to(new_user_session_path)
      end

      context 'in json' do
        it 'should return "access denied"' do
          get :show, id: commodity, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'should return an error' do
          get :show, id: commodity, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'get :new' do
      it 'should redirect to the sign in page' do
        get :new, entity_id: entity
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, entity_id: entity, commodity: attributes
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should not create the new commodity' do
        expect do
          post :create, entity_id: entity, commodity: attributes
        end.not_to change(Commodity, :count)
      end

      context 'in json' do
        it 'should return "access denied"' do
          post :create, entity_id: entity, commodity: attributes, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'should not create the new commodity' do
          expect do
            post :create, entity_id: entity, commodity: attributes, format: :json
          end.not_to change(Commodity, :count)
        end

        it 'should return an error' do
          post :create, entity_id: entity, commodity: attributes, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'get :edit' do
      it 'should redirect to the sign in page' do
        get :edit, id: commodity
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'put :update' do
      it 'should redirect to the sign in page' do
        put :update, id: commodity, commodity: attributes
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should not update the commodity' do
        expect do
          put :update, id: commodity, commodity: attributes
          commodity.reload
        end.not_to change(commodity, :name)
      end

      context 'in json' do
        it 'should return "access denied"' do
          put :update, id: commodity, commodity: attributes, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'should not update the commodity' do
          expect do
            put :update, id: commodity, commodity: attributes, format: :json
            commodity.reload
          end.not_to change(commodity, :name)
        end

        it 'should return an error' do
          put :update, id: commodity, commodity: attributes, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end

    describe 'delete :destroy' do
      it 'should redirect to the sign in page' do
        delete :destroy, id: commodity
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should not delete the commodity' do
        expect do
          delete :destroy, id: commodity
        end.not_to change(Commodity, :count)
      end

      context 'in json' do
        it 'should return "access denied"' do
          delete :destroy, id: commodity, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'should not delete the commodity' do
          expect do
            delete :destroy, id: commodity, format: :json
          end.not_to change(Commodity, :count)
        end

        it 'should return an error' do
          delete :destroy, id: commodity, format: :json
          expect(JSON.parse(response.body)).to have_only('error')
        end
      end
    end
  end
end
