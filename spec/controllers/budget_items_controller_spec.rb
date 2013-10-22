require 'spec_helper'

describe BudgetItemsController do

  let (:budget) { FactoryGirl.create(:budget) }
  let (:budget_item) { FactoryGirl.create(:budget_item, budget: budget) }
  
  context "for an authenticated user" do
    context "that owns the entity" do
      describe "get :index" do
        it "should be successful"
        context 'in json' do
          it 'should be successful'
          it 'should return the budget item list'
        end
      end

      describe "get :show" do
        it "should be successful"
        context 'in json' do
          it 'should be successful'
          it 'should return the budget item'
        end
      end

      describe "get :new" do
        it "should be successful"
      end

      describe "post :create" do
        it "should redirect to the budget item detail page"
        context 'in json' do
          it 'should be successful'
          it 'should create a new budget item'
          it 'should return the new budget item'
        end
      end

      describe "get :edit" do
        it "should be successful"
      end

      describe "put :update" do
        it "should redirect to the budget item detail page"
        context 'in json' do
          it 'should be successful'
          it 'should update the specified budget item'
          it 'should not return any data'
        end
      end

      describe "delete :destroy" do
        it "should redirect to the budget item index page"
        context 'in json' do
          it 'should be successful'
          it 'should delete the specified budget item'
        end
      end
    end
    
    context "that does not own the entity" do
      describe "get :index" do
        it 'should redirect to the user home page'
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end

      describe "get :show" do
        it 'should redirect to the user home page'
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end

      describe "get :new" do
        it 'should redirect to the user home page'
      end

      describe "post :create" do
        it 'should redirect to the user home page'
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not create a new budget item'
          it 'should not return any data'
        end
      end

      describe "get :edit" do
        it 'should redirect to the user home page'
      end

      describe "put :update" do
        it 'should redirect to the user home page'
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not update the specified budget item'
          it 'should not return any data'
        end
      end

      describe "delete :destroy" do
        it 'should redirect to the user home page'
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not delete the item'
          it 'should not return any data'
        end
      end
    end
  end
  
  context "for an unauthenticated user" do
    describe "get :index" do
      it 'should redirect to the sign in page' do
        get :index, budget_id: budget
        response.should redirect_to new_user_session_path
      end
      context 'in json' do
        it 'should return "access denied"' do
          get :index, budget_id: budget, format: :json
          response.response_code.should == 401
        end
        
        it 'should return an error message' do
          get :index, budget_id: budget, format: :json
          result = JSON.parse(response.body)
          result.should include('error')
          result.should have(1).item
        end
      end
    end

    describe "get :show" do
      it 'should redirect to the sign in page' do
        get :show, id: budget_item
        response.should redirect_to new_user_session_path
      end
      context 'in json' do
        it 'should return "access denied"' do
          get :show, id: budget_item, format: :json
          response.response_code.should == 401
        end
        
        it 'should return an error message' do
          get :show, id: budget_item, format: :json
          result = JSON.parse(response.body)
          result.should include('error')
          result.should have(1).item
        end
      end
    end

    describe "get :new" do
      it 'should redirect to the sign in page'
    end

    describe "post :create" do
      it 'should redirect to the sign in page'
      context 'in json' do
        it 'should return "access denied"'
        it 'should not create a new budget item'
        it 'should not return any data'
      end
    end

    describe "get :edit" do
      it 'should redirect to the sign in page'
    end

    describe "put :update" do
      it 'should redirect to the sign in page'
      context 'in json' do
        it 'should return "access denied"'
        it 'should not update the specified budget item'
        it 'should not return any data'
      end
    end

    describe "delete :destroy" do
      it 'should redirect to the sign in page'
      context 'in json' do
        it 'should return "access denied"'
        it 'should not delete the item'
        it 'should not return any data'
      end
    end
  end
end
