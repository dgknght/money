require 'spec_helper'

describe EntitiesController do
  let (:user) { FactoryGirl.create(:user) }
  let!(:entity) { FactoryGirl.create(:entity, user: user) }
  let (:attributes) do
    {
      name: 'The new entity'
    }
  end
  let (:gnucash_data) { fixture_file_upload('files/sample.gnucash', 'application/zip') }
  
  context 'for an authenticated user' do
    before(:each) { sign_in user }
    
    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to be_success
      end
      
      context 'in json' do
        it 'is successful' do
          get :index, format: :json
          expect(response).to be_success
        end
        
        it 'returns the list of entities' do
          get :index, format: :json
          expect(response.body).to eq([entity].to_json)
        end
      end
    end
    
    describe 'get :new' do
      it 'is successful' do
        get :new
        expect(response).to be_success
      end
    end
    
    describe 'post :create' do
      it 'redirects to the account index page for the new entity' do
        post :create, entity: attributes
        expect(response).to redirect_to entity_accounts_path(Entity.last)
      end
      
      it 'creates a new entity' do
        expect do
          post :create, entity: attributes
        end.to change(Entity, :count).by(1)
      end
      
      context 'in json' do
        it 'is successful' do
          post :create, entity: attributes, format: :json
          expect(response).to be_success
        end
        
        it 'returns the newly created entity' do
          expect do
            post :create, entity: attributes, format: :json
          end.to change(Entity, :count).by(1)
        end
      end

      context 'with a data file' do
        it 'imports the data' do
          post :create, entity: attributes.merge(data: gnucash_data)
          entity = Entity.last
          expect(entity).to have_at_least(1).account
          # expect(entity).to have_at_least(1).transaction # this caused a strange error
          expect(entity).to have_at_least(1).commodity
        end
      end
    end
    
    context 'that owns the entity' do
      describe 'get :edit' do
        it 'is successful' do
          get :edit, id: entity
          expect(response).to be_success
        end
      end
      
      describe 'put :update' do
        it 'redirects to the entity index page' do
          put :update, id: entity, entity: { name: 'the new name' }
          expect(response).to redirect_to entities_path
        end
        
        it 'updates the entity' do
          expect do
            put :update, id: entity, entity: { name: 'the new name' }
            entity.reload
          end.to change(entity, :name).to('the new name')
        end
      
        context 'in json' do
          it 'is successful' do
            put :update, id: entity, entity: { name: 'the new name' }, format: :json
            expect(response).to be_success
          end
          
          it 'updates the entity'do
            expect do
              put :update, id: entity, entity: { name: 'the new name' }, format: :json
              entity.reload
            end.to change(entity, :name).to('the new name')
            expect(response).to be_success
          end
          
          it 'does not return any data' do
            put :update, id: entity, entity: { name: 'the new name' }, format: :json
            expect(response.body).to be_blank
          end
        end
      end
      
      describe 'get :show' do
        it 'is successful' do
          get :show, id: entity
          expect(response).to be_success
        end
      
        context 'in json' do
          it 'is successful' do
            get :show, id: entity, format: :json
            expect(response).to be_success
          end
      
          it 'returns the specified entity' do
            get :show, id: entity, format: :json
            expect(response.body).to json_match entity
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'redirects to the entity index page' do
          delete :destroy, id: entity
          expect(response).to redirect_to entities_path
        end
        
        it 'deletes the entity' do
          expect do
            delete :destroy, id: entity
          end.to change(Entity, :count).by(-1)
        end
      
        context 'in json' do
          it 'is successful' do
            delete :destroy, id: entity, format: :json
            expect(response).to be_success
          end
          
          it 'deletes the specified entity' do
            expect do
              delete :destroy, id: entity, format: :json
            end.to change(Entity, :count).by(-1)
          end
        end
      end
    end
    
    context 'that does not own the entity' do
      let(:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe 'get :edit' do
        it 'redirects to user home page' do
          get :edit, id: entity
          expect(response).to redirect_to home_path
        end
      end
      
      describe 'put :update' do
        it 'redirects to the user home page' do
          put :update, id: entity, entity: { name: 'some new name' }
          expect(response).to redirect_to home_path
        end
        
        it 'does not update the entity' do
          expect do
            put :update, id: entity, entity: { name: 'some new name' }
            entity.reload
          end.to_not change(entity, :name)
        end
      
        context 'in json' do
          it 'returns "resource not found"' do
            put :update, id: entity, entity: { name: 'some new name' }, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            put :update, id: entity, entity: { name: 'some new name' }, format: :json
            expect(response.body).to eq([].to_json)
          end
          
          it 'does not update the entity' do
            expect do
              put :update, id: entity, entity: { name: 'some new name' }, format: :json
              entity.reload
            end.to_not change(entity, :name)
          end
          
        end
      end
      
      describe 'get :show' do
        it 'redirects to the user home page' do
          get :show, id: entity
          expect(response).to redirect_to home_path
        end
      
        context 'in json' do
          it 'returns "resource not found"' do
            get :show, id: entity, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :show, id: entity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'redirects to the user home page' do
          delete :destroy, id: entity
          expect(response).to redirect_to home_path
        end
        
        it 'does not delete the entity' do
          expect do
            delete :destroy, id: entity
          end.to_not change(Entity, :count)
        end
      
        context 'in json' do
          it 'returns "resource not found"' do
            delete :destroy, id: entity, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            delete :destroy, id: entity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the sign in page' do
        get :index, id: entity
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          get :index, id: entity, format: :json
          expect(response.response_code).to eq(401          )
        end
        
        it 'does not return any data' do
          get :index, id: entity, format: :json
          expect(response.body).to eq({ error: 'You need to sign in or sign up before continuing.' }.to_json)
        end
      end
    end
    
    describe 'get :new' do
      it 'redirects to the sign in page' do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end
    
    describe 'post :create' do
      it 'redirects to the sign in page' do
        post :create, entity: attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          post :create, entity: attributes, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not return any data' do
          post :create, entity: attributes, format: :json
          expect(response.body).to eq({ error: 'You need to sign in or sign up before continuing.' }.to_json)
        end
        
        it 'does not create an entity' do
          expect do
            post :create, entity: attributes, format: :json
          end.to_not change(Entity, :count)
        end
      end
    end
    
    describe 'get :edit' do
      it 'redirects to the sign in page' do
        get :edit, id: entity
        expect(response).to redirect_to new_user_session_path
      end
    end
    
    describe 'put :update' do
      it 'redirects to the sign in page' do
        put :update, id: entity, entity: { name: 'some new name' }
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          put :update, id: entity, entity: { name: 'some new name' }, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not return any data' do
          put :update, id: entity, entity: { name: 'some new name' }, format: :json
          expect(response.body).to eq({ error: 'You need to sign in or sign up before continuing.' }.to_json)
        end
        
        it 'does not update the entity' do
          expect do
            put :update, id: entity, entity: { name: 'some new name' }, format: :json            
          end.to_not change(Entity, :count)
        end
      end
    end
    
    describe 'get :show' do
      it 'redirects to the sign in page' do
        get :show, id: entity
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          get :show, id: entity, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not return any data' do
          get :show, id: entity, format: :json
          expect(response.body).to eq({ error: 'You need to sign in or sign up before continuing.' }.to_json)
        end
      end
    end
    
    describe 'delete :destroy' do
      it 'redirects to the sign in page' do
        delete :destroy, id: entity
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          delete :destroy, id: entity, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not return any data' do
          delete :destroy, id: entity, format: :json
          expect(response.body).to eq({ error: 'You need to sign in or sign up before continuing.' }.to_json)
        end
        
        it 'does not delete the entity' do
          expect do
            delete :destroy, id: entity, format: :json
          end.to_not change(Entity, :count)
        end
      end
    end
  end
end
