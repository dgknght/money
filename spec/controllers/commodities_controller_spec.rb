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
        it 'should redirect to the commodity list page'
        it 'should delete the commodity'

        context 'in json' do
          it 'should be successful'
          it 'should delete the commodity'
        end
      end
    end

    context 'that does not own the entity' do
      describe 'get :index' do
        it 'should redirect to the user home page'

        context 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end

      describe 'get :show' do
        it 'should redirect to the user home page'

        context 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end

      describe 'get :new' do
        it 'should redirect to the user home page'
      end

      describe 'post :create' do
        it 'should redirect to the user home page'
        it 'should not create the new commodity'

        context 'in json' do
          it 'should return "resource not found"'
          it 'should not create the new commodity'
          it 'should not return any data'
        end
      end

      describe 'get :edit' do
        it 'should redirect to the user home page'
      end

      describe 'put :update' do
        it 'should redirect to the user home page'
        it 'should not update the commodity'

        context 'in json' do
          it 'should return "resource not found"'
          it 'should not update the commodity'
          it 'should not return any data'
        end
      end

      describe 'delete :destroy' do
        it 'should redirect to the user home page'
        it 'should not delete the commodity'

        context 'in json' do
          it 'should return "resource not found"'
          it 'should not delete the commodity'
          it 'should not return any data'
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page'

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
      it 'should not create the new commodity'

      context 'in json' do
        it 'should return "access denied"'
        it 'should not create the new commodity'
        it 'should not return any data'
      end
    end

    describe 'get :edit' do
      it 'should redirect to the sign in page'
    end

    describe 'put :update' do
      it 'should redirect to the sign in page'
      it 'should not update the commodity'

      context 'in json' do
        it 'should return "access denied"'
        it 'should not update the commodity'
        it 'should not return any data'
      end
    end

    describe 'delete :destroy' do
      it 'should redirect to the sign in page'
      it 'should not delete the commodity'

      context 'in json' do
        it 'should return "access denied"'
        it 'should not delete the commodity'
        it 'should not return any data'
      end
    end
  end
end
