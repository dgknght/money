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
    end

    context 'that does not own the entity' do
    end
  end

  context 'for an unauthenticated user' do
  end

  describe "GET 'edit'" do
    it "returns http success" do
      get 'edit'
      response.should be_success
    end
  end

  describe "GET 'update'" do
    it "returns http success" do
      get 'update'
      response.should be_success
    end
  end

  describe "GET 'destroy'" do
    it "returns http success" do
      get 'destroy'
      response.should be_success
    end
  end

end
