require 'spec_helper'

describe EntitiesController do
  context 'for an authenticated user' do
    describe 'get :index' do
      it 'should be successful'
      
      context 'in json' do
        it 'should be successful'
        it 'should return the list of entities'
      end
    end
    describe 'get :new' do
      it 'should be successful'
    end
    describe 'post :create' do
      it 'should redirect to new entity detail page'
      it 'should create a new entity'
      
      context 'in json' do
        it 'should be successful'
        it 'should return the newly created entity'
      end
    end
    
    context 'that owns the entity' do
      describe 'get :edit' do
        it 'should be successful'
      end
      
      describe 'put :update' do
        it 'should redirect to the entity detail page'
        it 'should update the entity'
      
        context 'in json' do
          it 'should be successful'
          it 'should update the entity'
          it 'should not return any data'
        end
      end
      
      describe 'get :show' do
        it 'should be successful'
      
        context 'in json' do
          it 'should be successful'
          it 'should return the specified entity'
        end
      end
      
      describe 'delete :destroy' do
        it 'should redirect to the entity index page'
        it 'should delete the entity'
      
        context 'in json' do
          it 'should be successful'
          it 'should delete the specified entity'
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
