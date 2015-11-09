require 'spec_helper'

describe BudgetsController do
  let (:entity) { FactoryGirl.create(:entity) }
  
  let!(:budget) { FactoryGirl.create(:budget, entity_id: entity.id) }
  
  let (:attributes) do
    {
      name: 'The new budget',
      start_date: '2015-01-01',
      period: Budget.month,
      period_count: 12
    }
  end

  context 'for an authenticated user' do
    context 'to which the entity belongs' do
      before(:each) { sign_in entity.user }
      
      describe "get :index" do
        it "is successful" do
          get :index, entity_id: entity
          expect(response).to be_success
        end

        context 'in json' do
          it 'is successful' do
            get :index, entity_id: entity, format: :json
            expect(response).to be_success
          end

          it 'returns the list of budgets for the entity' do
            get :index, entity_id: entity, format: :json
            expect(response.body).to json_match [budget]
          end
        end
      end

      describe "get :show" do
        it "is successful" do
          get :show, id: budget
          expect(response).to be_success
        end

        context 'in json' do
          it 'is successful' do
            get :show, id: budget, format: :json
            expect(response).to be_success
          end

          it 'returns the specified budget' do
            get :show, id: budget, format: :json
            expect(response.body).to json_match budget
          end
        end
      end

      describe "get :new" do
        it 'is successful' do
          get :new, entity_id: entity
          expect(response).to be_success
        end
      end

      describe "post :create" do
        it 'creates a new budget' do
          expect do
            post :create, entity_id: entity, budget: attributes
          end.to change(Budget, :count).by(1)
        end
        
        it 'redirects to the budgets page' do
          post :create, entity_id: entity, budget: attributes
          expect(response).to redirect_to entity_budgets_path(entity)
        end
        
        context 'in json' do
          it 'creates the new budget' do
            expect do
              post :create, entity_id: entity, budget: attributes, format: :json
            end.to change(Budget, :count).by(1)
          end
          
          it 'returns the new budget record' do
            post :create, entity_id: entity, budget: attributes, format: :json
            expect(response.body).to json_match attributes
          end
        end
      end

      describe "get :edit" do
        it 'is successful' do
          get :edit, id: budget
          expect(response).to be_success
        end
      end

      describe "put :update" do
        it 'updates the budget' do
          expect do
            put :update, id: budget, budget: attributes
            budget.reload
          end.to change(budget, :name).to('The new budget')
        end
        
        it 'redirects to the budget detail page' do
          put :update, id: budget, budget: attributes
          expect(response).to redirect_to budget_path(budget)
        end
        
        context 'in json' do
          it 'is successful' do
            put :update, id: budget, budget: attributes, format: :json
            expect(response).to be_success
          end
          
          it 'updates the budget' do
            expect do
              put :update, id: budget, budget: attributes, format: :json
              budget.reload
            end.to change(budget, :name).to('The new budget')
          end
          
          it 'does not return any data' do
            put :update, id: budget, budget: attributes, format: :json
            expect(response.body).to be_blank
          end
        end
      end

      describe "delete :destroy" do
        it 'redirects to the budget index page' do
          delete :destroy, id: budget
          expect(response).to redirect_to entity_budgets_path(entity)
        end
        
        it 'removes the budget' do
          expect do
            delete :destroy, id: budget
          end.to change(Budget, :count).by(-1)
        end
        
        context 'in json' do
          it 'is successful' do
            delete :destroy, id: budget, format: :json
            expect(response).to be_success
          end
          
          it 'removes the budget' do
            expect do
              delete :destroy, id: budget, format: :json
            end.to change(Budget, :count).by(-1)
          end
          
          it 'does not return any data' do
            delete :destroy, id: budget, format: :json
            expect(response.body).to be_blank
          end
        end
      end
    end
    
    context 'to which the entity does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe 'get :index' do
        it 'redirects to the user home page' do
          get :index, entity_id: entity
          expect(response).to redirect_to home_path
        end
        
        describe 'in json' do
          it 'returns "resource not found"' do
            get :index, entity_id: entity, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :index, entity_id: entity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
      describe 'get :show' do
        it 'redirects to the user home page' do
          get :show, id: budget
          expect(response).to redirect_to home_path
        end
        
        describe 'in json' do
          it 'returns "resource not found"' do
            get :show, id: budget, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :show, id: budget, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
      describe 'get :new' do
        it 'redirects to the user home page' do
          get :new, entity_id: entity
          expect(response).to redirect_to home_path
        end
        
        describe 'in json' do
          it 'returns "resource not found"' do
            get :new, entity_id: entity, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :new, entity_id: entity, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
      describe 'post :create' do
        it 'redirects to the user home page' do
          post :create, entity_id: entity, budget: attributes
          expect(response).to redirect_to home_path
        end
        
        it 'does not create a budget' do
          expect do
            post :create, entity_id: entity, budget: attributes
          end.not_to change(Budget, :count)
        end
        
        describe 'in json' do
          it 'returns "resource not found"' do
            post :create, entity_id: entity, budget: attributes, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            post :create, entity_id: entity, budget: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
          
          it 'does not create a budget' do
            expect do
              post :create, entity_id: entity, budget: attributes, format: :json
            end.not_to change(Budget, :count)
          end
        end
      end
      
      describe 'get :edit' do
        it 'redirects to the user home page' do
          get :edit, id: budget
          expect(response).to redirect_to home_path
        end
        
        describe 'in json' do
          it 'returns "resource not found"' do
            get :edit, id: budget, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :edit, id: budget, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
      
      describe 'put :update' do
        it 'redirects to the user home page' do
          put :update, id: budget, budget: attributes
          expect(response).to redirect_to home_path
        end
        
        it 'does not update the budget' do
          expect do
            put :update, id: budget, budget: attributes
            budget.reload
          end.not_to change(budget, :name)
        end
        
        describe 'in json' do
          it 'returns "resource not found"' do
            put :update, id: budget, budget: attributes, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            put :update, id: budget, budget: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
          
          it 'does not update the budget' do
            expect do
              put :update, id: budget, budget: attributes, format: :json
              budget.reload
            end.not_to change(budget, :name)
          end
        end
      end
      
      describe 'delete :destroy' do
        it 'redirects to the user home page' do
          delete :destroy, id: budget
          expect(response).to redirect_to home_path
        end
        
        it 'does not delete the budget' do
          expect do
            delete :destroy, id: budget
          end.not_to change(Budget, :count)
        end
        
        describe 'in json' do
          it 'returns "resource not found"' do
            delete :destroy, id: budget, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            delete :destroy, id: budget, format: :json
            expect(response.body).to eq([].to_json)
          end
          
          it 'does not delete the budget' do
            expect do
              delete :destroy, id: budget, format: :json
            end.not_to change(Budget, :count)
          end
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the sign in page' do
        get :index, entity_id: entity
        expect(response).to redirect_to new_user_session_path
      end
      
      describe 'in json' do
        it 'returns "access denied"' do
          get :index, entity_id: entity, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error message' do
          get :index, entity_id: entity, format: :json
          result = JSON.parse(response.body)
          expect(result).to have(1).item
          expect(result).to include 'error'
        end
      end
    end
    
    describe 'get :new' do
      it 'redirects to the sign in page' do
        get :new, entity_id: entity
        expect(response).to redirect_to new_user_session_path
      end
      
      describe 'in json' do
        it 'returns "access denied"' do
          get :new, entity_id: entity, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error message' do
          get :new, entity_id: entity, format: :json
          result = JSON.parse(response.body)
          expect(result).to have(1).item
          expect(result).to include 'error'
        end
      end
    end
    
    describe 'post :create' do
      it 'redirects to the sign in page' do
        post :create, entity_id: entity, budget: attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      describe 'in json' do
        it 'returns "access denied"' do
          post :create, entity_id: entity, budget: attributes, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error message' do
          post :create, entity_id: entity, budget: attributes, format: :json
          result = JSON.parse(response.body)
          expect(result).to have(1).item
          expect(result).to include 'error'
        end
        
        it 'does not create a budget' do
          expect do
            post :create, entity_id: entity, budget: attributes, format: :json
          end.not_to change(Budget, :count)
        end
      end
    end
    
    describe 'get :edit' do
      it 'redirects to the sign in page' do
        get :edit, id: budget
        expect(response).to redirect_to new_user_session_path
      end
      
      describe 'in json' do
        it 'returns "access denied"' do
          get :edit, id: budget, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error message' do
          get :edit, id: budget, format: :json
          result = JSON.parse(response.body)
          expect(result).to have(1).item
          expect(result).to include 'error'
        end
      end
    end
    
    describe 'put :update' do
      it 'redirects to the sign in page' do
        put :update, id: budget, budget: attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      describe 'in json' do
        it 'returns "access denied"' do
          put :update, id: budget, budget: attributes, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error message' do
          put :update, id: budget, budget: attributes, format: :json
          result = JSON.parse(response.body)
          expect(result).to have(1).item
          expect(result).to include 'error'
        end
        
        it 'does not update the budget' do
          expect do
            put :update, id: budget, budget: attributes, format: :json
            budget.reload
          end.not_to change(budget, :name)
        end
      end
    end
    
    describe 'delete :destroy' do
      it 'redirects to the sign in page' do
        delete :destroy, id: budget
        expect(response).to redirect_to new_user_session_path
      end
      
      describe 'in json' do
        it 'returns "access denied"' do
          delete :destroy, id: budget, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error message' do
          delete :destroy, id: budget, format: :json
          result = JSON.parse(response.body)
          expect(result).to have(1).item
          expect(result).to include 'error'
        end
        
        it 'does not delete the budget' do
          expect do
            delete :destroy, id: budget, format: :json
          end.not_to change(Budget, :count)
        end
      end
    end
  end
end
