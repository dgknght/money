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
      it 'should be successful' do
        get :index
        response.should be_success
      end
      
      context 'in json' do
        it 'should be successful' do
          get :index, format: :json
          response.should be_success
        end
        
        it 'should return the list of entities' do
          get :index, format: :json
          response.body.should == [entity].to_json
        end
      end
    end
    
    describe 'get :new' do
      it 'should be successful' do
        get :new
        response.should be_success
      end
    end
    
    describe 'post :create' do
      it 'should redirect to new entity detail page' do
        post :create, entity: attributes
        response.should redirect_to entity_path(Entity.last)
      end
      
      it 'should create a new entity' do
        lambda do
          post :create, entity: attributes
        end.should change(Entity, :count).by(1)
      end
      
      context 'in json' do
        it 'should be successful' do
          post :create, entity: attributes, format: :json
          response.should be_success
        end
        
        it 'should return the newly created entity' do
          lambda do
            post :create, entity: attributes, format: :json
          end.should change(Entity, :count).by(1)
        end
      end
    end
    
    context 'that owns the entity' do
      describe 'get :edit' do
        it 'should be successful' do
          get :edit, id: entity
          response.should be_success
        end
      end
      
      describe 'put :update' do
        it 'should redirect to the entity detail page' do
          put :update, id: entity, entity: { name: 'the new name' }
          response.should redirect_to entity_path(entity)
        end
        
        it 'should update the entity' do
          lambda do
            put :update, id: entity, entity: { name: 'the new name' }
            entity.reload
          end.should change(entity, :name).to('the new name')
        end
      
        context 'in json' do
          it 'should be successful' do
            put :update, id: entity, entity: { name: 'the new name' }, format: :json
            response.should be_success
          end
          
          it 'should update the entity'do
            lambda do
              put :update, id: entity, entity: { name: 'the new name' }, format: :json
              entity.reload
            end.should change(entity, :name).to('the new name')
            response.should be_success
          end
          
          it 'should not return any data' do
            put :update, id: entity, entity: { name: 'the new name' }, format: :json
            response.body.should == ""
          end
        end
      end
      
      describe 'get :show' do
        it 'should be successful' do
          get :show, id: entity
          response.should be_success
        end
      
        context 'in json' do
          it 'should be successful' do
            get :show, id: entity, format: :json
            response.should be_success
          end
      
          it 'should return the specified entity' do
            get :show, id: entity, format: :json
            response.body.should == entity.to_json
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'should redirect to the entity index page' do
          delete :destroy, id: entity
          response.should redirect_to entities_path
        end
        
        it 'should delete the entity' do
          lambda do
            delete :destroy, id: entity
          end.should change(Entity, :count).by(-1)
        end
      
        context 'in json' do
          it 'should be successful' do
            delete :destroy, id: entity, format: :json
            response.should be_success
          end
          
          it 'should delete the specified entity' do
            lambda do
              delete :destroy, id: entity, format: :json
            end.should change(Entity, :count).by(-1)
          end
        end
      end

      describe 'get :import' do
        it 'should be successful' do
          get :import, id: entity
          expect(response).to be_success
        end
      end

      describe 'get :new_gnucash' do
        it 'should be successful' do
          get :new_gnucash, id: entity
          expect(response).to be_success
        end
      end

      describe 'post :gnucash' do
        it 'should redirect to the accounts page' do
          post :gnucash, id: entity, import: gnucash_data
          expect(response).to redirect_to(entity_accounts_path(entity))
        end

        it 'should create the specified accounts'
        it 'should create the specified transactions'
      end
    end
    
    context 'that does not own the entity' do
      let(:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe 'get :edit' do
        it 'should redirect to user home page' do
          get :edit, id: entity
          response.should redirect_to home_path
        end
      end
      
      describe 'put :update' do
        it 'should redirect to the user home page' do
          put :update, id: entity, entity: { name: 'some new name' }
          response.should redirect_to home_path
        end
        
        it 'should not update the entity' do
          lambda do
            put :update, id: entity, entity: { name: 'some new name' }
            entity.reload
          end.should_not change(entity, :name)
        end
      
        context 'in json' do
          it 'should return "resource not found"' do
            put :update, id: entity, entity: { name: 'some new name' }, format: :json
            response.response_code.should == 404
          end
          
          it 'should not return any data' do
            put :update, id: entity, entity: { name: 'some new name' }, format: :json
            response.body.should == [].to_json
          end
          
          it 'should not update the entity' do
            lambda do
              put :update, id: entity, entity: { name: 'some new name' }, format: :json
              entity.reload
            end.should_not change(entity, :name)
          end
          
        end
      end
      
      describe 'get :show' do
        it 'should redirect to the user home page' do
          get :show, id: entity
          response.should redirect_to home_path
        end
      
        context 'in json' do
          it 'should return "resource not found"' do
            get :show, id: entity, format: :json
            response.response_code.should == 404
          end
          
          it 'should not return any data' do
            get :show, id: entity, format: :json
            response.body.should == [].to_json
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'should redirect to the user home page' do
          delete :destroy, id: entity
          response.should redirect_to home_path
        end
        
        it 'should not delete the entity' do
          lambda do
            delete :destroy, id: entity
          end.should_not change(Entity, :count)
        end
      
        context 'in json' do
          it 'should return "resource not found"' do
            delete :destroy, id: entity, format: :json
            response.response_code.should == 404
          end
          
          it 'should not return any data' do
            delete :destroy, id: entity, format: :json
            response.body.should == [].to_json
          end
        end
      end

      describe 'get :import' do
        it 'should redirect to the user home page' do
          get :import, id: entity
          expect(response).to redirect_to(home_path)
        end
      end

      describe 'get :new_gnucash' do
        it 'should return "resource not found"' do
          get :new_gnucash, id: entity
          expect(response).to redirect_to(home_path)
        end
      end

      describe 'post :gnucash' do
        it 'should redirect to the user home page'
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index, id: entity
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :index, id: entity, format: :json
          response.response_code.should == 401          
        end
        
        it 'should not return any data' do
          get :index, id: entity, format: :json
          response.body.should == { error: 'You need to sign in or sign up before continuing.' }.to_json
        end
      end
    end
    
    describe 'get :new' do
      it 'should redirect to the sign in page' do
        get :new
        response.should redirect_to new_user_session_path
      end
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, entity: attributes
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          post :create, entity: attributes, format: :json
          response.response_code.should == 401
        end
        
        it 'should not return any data' do
          post :create, entity: attributes, format: :json
          response.body.should == { error: 'You need to sign in or sign up before continuing.' }.to_json
        end
        
        it 'should not create an entity' do
          lambda do
            post :create, entity: attributes, format: :json
          end.should_not change(Entity, :count)
        end
      end
    end
    
    describe 'get :edit' do
      it 'should redirect to the sign in page' do
        get :edit, id: entity
        response.should redirect_to new_user_session_path
      end
    end
    
    describe 'put :update' do
      it 'should redirect to the sign in page' do
        put :update, id: entity, entity: { name: 'some new name' }
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          put :update, id: entity, entity: { name: 'some new name' }, format: :json
          response.response_code.should == 401
        end
        
        it 'should not return any data' do
          put :update, id: entity, entity: { name: 'some new name' }, format: :json
          response.body.should == { error: 'You need to sign in or sign up before continuing.' }.to_json
        end
        
        it 'should not update the entity' do
          lambda do
            put :update, id: entity, entity: { name: 'some new name' }, format: :json            
          end.should_not change(Entity, :count)
        end
      end
    end
    
    describe 'get :show' do
      it 'should redirect to the sign in page' do
        get :show, id: entity
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          get :show, id: entity, format: :json
          response.response_code.should == 401
        end
        
        it 'should not return any data' do
          get :show, id: entity, format: :json
          response.body.should == { error: 'You need to sign in or sign up before continuing.' }.to_json
        end
      end
    end
    
    describe 'delete :destroy' do
      it 'should redirect to the sign in page' do
        delete :destroy, id: entity
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          delete :destroy, id: entity, format: :json
          response.response_code.should == 401
        end
        
        it 'should not return any data' do
          delete :destroy, id: entity, format: :json
          response.body.should == { error: 'You need to sign in or sign up before continuing.' }.to_json
        end
        
        it 'should not delete the entity' do
          lambda do
            delete :destroy, id: entity, format: :json
          end.should_not change(Entity, :count)
        end
      end
    end

    describe 'get :import' do
      it 'should redirect to the sign in page' do
        get :import, id: entity
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'get :new_gnucash' do
      it 'should redirect to the sign in page' do
        get :new_gnucash, id: entity
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'post :gnucash' do
      it 'should redirect to the sign in page'
    end
  end
end
