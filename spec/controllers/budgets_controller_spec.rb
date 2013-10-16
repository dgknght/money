require 'spec_helper'

describe BudgetsController do
  let (:entity) { FactoryGirl.create(:entity) }
  
  let!(:budget) { FactoryGirl.create(:budget, entity_id: entity.id) }
  
  let (:attributes) do
    {
      name: 'The new budget',
      start_date: '2015-01-01',
      end_date: '2015-12-31'
    }
  end

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
        it 'should be successful' do
          get :new, entity_id: entity
          response.should be_success
        end
      end

      describe "post :create" do
        it 'should create a new budget' do
          lambda do
            post :create, entity_id: entity, budget: attributes
          end.should change(Budget, :count).by(1)
        end
        
        it 'should redirect to the budget detail page' do
          post :create, entity_id: entity, budget: attributes
          response.should redirect_to budget_path(Budget.last)
        end
        
        context 'in json' do
          it 'should create the new budget' do
            lambda do
              post :create, entity_id: entity, budget: attributes, format: :json
            end.should change(Budget, :count).by(1)
          end
          
          it 'should return the new budget record' do
            post :create, entity_id: entity, budget: attributes, format: :json
            result = JSON.parse(response.body)            
            attributes.each { |k, v| result[k.to_s].should == v}
          end
        end
      end

      describe "get :edit" do
        it 'should be successful' do
          get :edit, id: budget
          response.should be_success
        end
      end

      describe "put :update" do
        it 'should update the budget' do
          lambda do
            put :update, id: budget, budget: attributes
            budget.reload
          end.should change(budget, :name).to('The new budget')          
        end
        
        it 'should redirect to the budget detail page' do
          put :update, id: budget, budget: attributes
          response.should redirect_to budget_path(budget)
        end
        
        context 'in json' do
          it 'should be successful' do
            put :update, id: budget, budget: attributes, format: :json
            response.should be_success
          end
          
          it 'should update the budget' do
            lambda do
              put :update, id: budget, budget: attributes, format: :json
              budget.reload
            end.should change(budget, :name).to('The new budget')
          end
          
          it 'should not return any data' do
            put :update, id: budget, budget: attributes, format: :json
            response.body.should == ""
          end
        end
      end

      describe "delete :destroy" do
        it 'should redirect to the budget index page' do
          delete :destroy, id: budget
          response.should redirect_to entity_budgets_path(entity)
        end
        
        it 'should remove the budget' do
          lambda do
            delete :destroy, id: budget
          end.should change(Budget, :count).by(-1)
        end
        
        context 'in json' do
          it 'should be successful' do
            delete :destroy, id: budget, format: :json
            response.should be_success
          end
          
          it 'should remove the budget' do
            lambda do
              delete :destroy, id: budget, format: :json
            end.should change(Budget, :count).by(-1)
          end
          
          it 'should not return any data' do
            delete :destroy, id: budget, format: :json
            response.body.should == ""
          end
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
