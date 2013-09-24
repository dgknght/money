require 'spec_helper'

describe EntitiesController do
  let (:user) { FactoryGirl.create(:user) }
  let!(:entity) { FactoryGirl.create(:entity, user: user) }
  let (:attributes) do
    {
      name: 'The new entity'
    }
  end
  
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
            response.body.should == " "
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
    end
    
    context 'that does not own the entity' do
      describe 'get :edit' do
        it 'should redirect to entity index page'
      
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end
      
      describe 'put :update' do
        it 'should redirect to entity index page'
        it 'should not update the entity'
      
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
          it 'should not update the entity'
        end
      end
      
      describe 'get :show' do
        it 'should redirect to the entity index page'
      
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end
      
      describe 'delete :destroy' do
        it 'should redirect to the entity index page'
        it 'should not delete the entity'
      
        context 'in json' do
          it 'should return "resource not found"'
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
    
    describe 'get :new' do
      it 'should redirect to the sign in page'
    end
    
    describe 'post :create' do
      it 'should redirect to the sign in page'
      
      context 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
        it 'should not create an entity'
      end
    end
    
    describe 'get :edit' do
      it 'should redirect to the sign in page'
    end
    
    describe 'put :update' do
      it 'should redirect to the sign in page'
      
      context 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
        it 'should not update the entity'
      end
    end
    
    describe 'get :show' do
      it 'should redirect to the sign in page'
      
      context 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
      end
    end
    
    describe 'delete :destroy' do
      it 'should redirect to the sign in page'
      
      context 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
        it 'should not delete the entity'
      end
    end
  end
end
