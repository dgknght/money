require 'spec_helper'

describe PricesController do

  context 'for an authenticated user' do
    context 'that owns the entity' do

      describe 'get :index' do
        it 'should be successful'

        context 'in json' do
          it 'should be successful'
          it 'should return the list of commodity prices'
        end
      end

      describe 'get :show' do
        it 'should be successful'

        context 'in json' do
          it 'should be successful'
          it 'should return the specified commodity price'
        end
      end

      describe 'get :new' do
        it 'should be successful'
      end

      describe 'post :create' do
        it 'should redirect to the commodity price index page'
        it 'should create a new commodity price'

        context 'in json' do
          it 'should be successful'
          it 'should create a new commodity price'
          it 'should return the new commodity price'
        end
      end

      describe 'get :edit' do
        it 'should be successful'
      end

      describe 'put :update' do
        it 'should redirect to the commodity prices index page'
        it' should update the specified commodity'

        context 'in json' do
          it 'should be successful'
          it 'should update the specified commodity'
        end
      end

      describe 'delete :destroy' do
        it 'should redirect to the commodity prices index page'
        it 'should delete the specified commodity'

        context 'in json' do

          it 'should be successful'
          it 'should delete the specified commodity'
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
        it 'should not create a new commodity price'

        context 'in json' do
          it 'should return "resource not found"'
          it 'should not create a new commodity price'
          it 'should not return any data'
        end
      end

      describe 'get :edit' do
        it 'should redirect to the user home page'
      end

      describe 'put :update' do
        it 'should redirect to the user home page'
        it' should not update the specified commodity'

        context 'in json' do
          it 'should return "resource not found"'
          it 'should not update the specified commodity'
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
