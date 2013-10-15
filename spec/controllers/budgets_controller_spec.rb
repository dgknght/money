require 'spec_helper'

describe BudgetsController do
  let (:entity) { FactoryGirl.create(:entity) }
  
  let!(:budget) { FactoryGirl.create(:budget, entity_id: entity.id) }

  context 'for an authenticated user' do
    context 'to which the entity belongs' do
      before(:each) { sign_in entity.user }
      
      describe "get :index" do
        it "should be successful" do
          get :index, entity_id: entity
          response.should be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :index, entity_id: entity, format: :json
            response.should be_success
          end

          it 'should return the list of budgets for the entity' do
            get :index, entity_id: entity, format: :json
            response.body.should == [budget].to_json
          end
        end
      end

      describe "get :show" do
        it "should be successful" do
          get :show, id: budget
          response.should be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :show, id: budget, format: :json
            response.should be_success
          end

          it 'should return the specified budget' do
            get :show, id: budget, format: :json
            response.body.should == budget.to_json
          end
        end
      end

      describe "get :new" do
        it 'should be successful'
      end

      describe "post :create" do
        it 'should create a new budget'
        it 'should redirect to the budget detail page'
        context 'in json' do
          it 'should create the new budget'
          it 'should return the new budget record'
        end
      end

      describe "get :edit" do
        it 'should be successful'
      end

      describe "put :update" do
        it 'should update the budget'
        it 'should redirect to the budget detail page'
        context 'in json' do
          it 'should be successful'
          it 'should update the budget'
          it 'should not return any data'
        end
      end

      describe "delete :destroy" do
        it 'should redirect to the budget index page'
        it 'should remove the budget'
        context 'in json' do
          it 'should be successful'
          it 'should remove the budget'
          it 'should not return any data'
        end
      end
    end
    
    context 'to which the entity does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe 'get :index' do
        it 'should redirect to the user home page'
        describe 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end
      describe 'get :show' do
        it 'should redirect to the user home page'
        describe 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end
      describe 'get :new' do
        it 'should redirect to the user home page'
        describe 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end
      describe 'post :create' do
        it 'should redirect to the user home page'
        it 'should not create a budget'
        describe 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
          it 'should not create a budget'
        end
      end
      describe 'get :edit' do
        it 'should redirect to the user home page'
        describe 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
        end
      end
      describe 'put :update' do
        it 'should redirect to the user home page'
        it 'should not update the budget'
        describe 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
          it 'should not update the budget'
        end
      end
      describe 'delete :destroy' do
        it 'should redirect to the user home page'
        it 'should not delete the budget'
        describe 'in json' do
          it 'should return "resource not found"'
          it 'should not return any data'
          it 'should not delete the budget'
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page'
      describe 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
      end
    end
    describe 'get :new' do
      it 'should redirect to the sign in page'
      describe 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
      end
    end
    describe 'post :create' do
      it 'should redirect to the sign in page'
      describe 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
        it 'should not create a budget'
      end
    end
    describe 'get :edit' do
      it 'should redirect to the sign in page'
      describe 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
      end
    end
    describe 'put :update' do
      it 'should redirect to the sign in page'
      describe 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
        it 'should not update the budget'
      end
    end
    describe 'delete :destroy' do
      it 'should redirect to the sign in page'
      describe 'in json' do
        it 'should return "access denied"'
        it 'should not return any data'
        it 'should not delete the budget'
      end
    end
  end
end
