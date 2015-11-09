require 'spec_helper'

describe BudgetItemsController do

  let (:budget) { FactoryGirl.create(:budget) }
  let (:account) { FactoryGirl.create(:account, entity: budget.entity) }
  let!(:budget_item) { FactoryGirl.create(:budget_item, budget: budget) }
  let (:attributes) do
    {
      budget_id: budget.id,
      account_id: account.id      
    }
  end
  let (:distributor) do
    {
      method: BudgetItemDistributor.average,
      options: {
        amount: 100
      }
    }
  end
  
  context "for an authenticated user" do
    context "that owns the entity" do
      before(:each) { sign_in budget.entity.user }
      
      describe "get :index" do
        it "is successful" do
          get :index, budget_id: budget
          expect(response).to be_success
        end
        
        context 'in json' do
          it 'is successful' do
            get :index, budget_id: budget, format: :json
            expect(response).to be_success
          end
          
          it 'returns the budget item list' do
            get :index, budget_id: budget, format: :json
            expect(response.body).to json_match [budget_item]
          end
        end
      end

      describe "get :show" do
        it "is successful" do
          get :show, id: budget_item
          expect(response).to be_success
        end
        
        context 'in json' do
          it 'is successful' do
            get :show, id: budget_item, format: :json
            expect(response).to be_success
          end
          
          it 'returns the budget item' do
            get :show, id: budget_item, format: :json
            expect(response.body).to json_match budget_item
          end
        end
      end

      describe "get :new" do
        it "is successful" do
          get :new, budget_id: budget
          expect(response).to be_success
        end
      end

      describe "post :create" do
        it "redirects to the budget item detail page" do
          post :create, budget_id: budget, budget_item: attributes, distributor: distributor
          expect(response).to redirect_to budget_budget_items_path(budget)
        end
        
        it 'creates a new budget item' do
          expect do
            post :create, budget_id: budget, budget_item: attributes, distributor: distributor
          end.to change(BudgetItem, :count).by(1)
        end
        
        it 'creates the correct budget amounts for each period' do
          post :create, budget_id: budget, budget_item: attributes, distributor: distributor
          budget_item = BudgetItem.last
          expect(budget_item.periods.map{ |p| p.budget_amount }).to eq((1..12).map{ |i| 100})
        end
        
        context 'in json' do
          it 'is successful' do
            post :create, budget_id: budget, budget_item: attributes, distributor: distributor, format: :json
            expect(response).to be_success
          end
          
          it 'creates a new budget item' do
            expect do
              post :create, budget_id: budget, budget_item: attributes, distributor: distributor, format: :json
            end.to change(BudgetItem, :count).by(1)
          end
          
          it 'returns the new budget item' do
            post :create, budget_id: budget, budget_item: attributes, distributor: distributor, format: :json
            expect(response.body).to json_match attributes
          end
        end
      end

      describe "get :edit" do
        it "is successful" do
          get :edit, id: budget_item
          expect(response).to be_success
        end
      end

      describe "put :update" do
        it "redirects to the budget item index page" do
          put :update, id: budget_item, budget_item: attributes, distributor: distributor
          expect(response).to redirect_to budget_budget_items_path(budget_item.budget)
        end
        
        it 'updates the budget item' do
          expect do
            put :update, id: budget_item, budget_item: attributes, distributor: distributor
            budget_item.reload
          end.to change(budget_item, :account_id).to(account.id)
        end
        
        context 'in json' do
          it 'is successful' do
            put :update, id: budget_item, budget_item: attributes, distributor: distributor, format: :json
            expect(response).to be_success
          end
          
          it 'updates the specified budget item' do
            expect do
              put :update, id: budget_item, budget_item: attributes, distributor: distributor, format: :json
              budget_item.reload
            end.to change(budget_item, :account_id).to(account.id)
          end
          
          it 'does not return any data' do
            put :update, id: budget_item, budget_item: attributes, distributor: distributor, format: :json
            expect(response.body).to be_blank
          end
        end
      end

      describe "delete :destroy" do
        it "redirects to the budget item index page" do
          delete :destroy, id: budget_item
          expect(response).to redirect_to budget_budget_items_path(budget)
        end
        
        it 'deletes the budget item' do
          expect do
            delete :destroy, id: budget_item
          end.to change(BudgetItem, :count).by(-1)
        end
        
        context 'in json' do
          it 'is successful' do
            delete :destroy, id: budget_item, format: :json
            expect(response).to be_success
          end
          
          it 'deletes the specified budget item' do
            expect do
              delete :destroy, id: budget_item, format: :json
            end.to change(BudgetItem, :count).by(-1)
          end
        end
      end
    end
    
    context "that does not own the entity" do
      let(:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }
      
      describe "get :index" do
        it 'redirects to the user home page' do
          get :index, budget_id: budget
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            get :index, budget_id: budget, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :index, budget_id: budget, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe "get :show" do
        it 'redirects to the user home page' do
          get :show, id: budget_item
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            get :show, id: budget_item, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not return any data' do
            get :show, id: budget_item, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe "get :new" do
        it 'redirects to the user home page' do
          get :new, budget_id: budget
          expect(response).to redirect_to home_path
        end
      end

      describe "post :create" do
        it 'redirects to the user home page' do
          post :create, budget_id: budget, budget_item: attributes
          expect(response).to redirect_to home_path
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            post :create, budget_id: budget, budget_item: attributes, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not create a new budget item' do
            expect do
              post :create, budget_id: budget, budget_item: attributes, format: :json
            end.not_to change(BudgetItem, :count)
          end
          
          it 'does not return any data' do
            post :create, budget_id: budget, budget_item: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe "get :edit" do
        it 'redirects to the user home page' do
          get :edit, id: budget_item
          expect(response).to redirect_to home_path
        end
      end

      describe "put :update" do
        it 'redirects to the user home page' do
          put :update, id: budget_item, budget_item: attributes
          expect(response).to redirect_to home_path
        end
        
        it 'does not update the item' do
          expect do
            put :update, id: budget_item, budget_item: attributes
            budget_item.reload
          end.not_to change(budget_item, :account_id)
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            put :update, id: budget_item, budget_item: attributes, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not update the specified budget item' do
            expect do
              put :update, id: budget_item, budget_item: attributes, format: :json
              budget_item.reload
            end.not_to change(budget_item, :account_id)
          end
          
          it 'does not return any data' do
            put :update, id: budget_item, budget_item: attributes, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe "delete :destroy" do
        it 'redirects to the user home page' do
          delete :destroy, id: budget_item
          expect(response).to redirect_to home_path
        end
        
        it 'does not delete the budget item' do
          expect do
            delete :destroy, id: budget_item
          end.not_to change(BudgetItem, :count)
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            delete :destroy, id: budget_item, format: :json
            expect(response.response_code).to eq(404)
          end
          
          it 'does not delete the item' do
            expect do
              delete :destroy, id: budget_item, format: :json
            end.not_to change(BudgetItem, :count)
          end
          
          it 'does not return any data' do
            delete :destroy, id: budget_item, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
    end
  end
  
  context "for an unauthenticated user" do
    describe "get :index" do
      it 'redirects to the sign in page' do
        get :index, budget_id: budget
        expect(response).to redirect_to new_user_session_path
      end
      context 'in json' do
        it 'returns "access denied"' do
          get :index, budget_id: budget, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error message' do
          get :index, budget_id: budget, format: :json
          result = JSON.parse(response.body)
          expect(result).to include('error')
          expect(result).to have(1).item
        end
      end
    end

    describe "get :show" do
      it 'redirects to the sign in page' do
        get :show, id: budget_item
        expect(response).to redirect_to new_user_session_path
      end
      context 'in json' do
        it 'returns "access denied"' do
          get :show, id: budget_item, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'returns an error message' do
          get :show, id: budget_item, format: :json
          result = JSON.parse(response.body)
          expect(result).to include('error')
          expect(result).to have(1).item
        end
      end
    end

    describe "get :new" do
      it 'redirects to the sign in page' do
        get :new, budget_id: budget
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "post :create" do
      it 'redirects to the sign in page' do
        post :create, budget_id: budget, budget_item: attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          post :create, budget_id: budget, budget_item: attributes, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not create a new budget item' do
          expect do
            post :create, budget_id: budget, budget_item: attributes, format: :json
          end.not_to change(BudgetItem, :count)
        end
        
        it 'returns an error message' do
          post :create, budget_id: budget, budget_item: attributes, format: :json
          result = JSON.parse(response.body)
          expect(result).to include('error')
          expect(result).to have(1).item
        end
      end
    end

    describe "get :edit" do
      it 'redirects to the sign in page' do
        get :edit, id: budget_item
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "put :update" do
      it 'redirects to the sign in page' do
        put :update, id: budget_item, budget_item: attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          put :update, id: budget_item, budget_item: attributes, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not update the specified budget item' do
          expect do
            put :update, id: budget_item, budget_item: attributes, format: :json
            budget_item.reload
          end.not_to change(budget_item, :account_id)
        end
        
        it 'returns an error message' do
          put :update, id: budget_item, budget_item: attributes, format: :json
          result = JSON.parse(response.body)
          expect(result).to include('error')
          expect(result).to have(1).item
        end
      end
    end

    describe "delete :destroy" do
      it 'redirects to the sign in page' do
        delete :destroy, id: budget_item
        expect(response).to redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          delete :destroy, id: budget_item, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not delete the item' do
          expect do
            delete :destroy, id: budget_item, format: :json
          end.not_to change(BudgetItem, :count)
        end
        
        it 'returns an error message' do
          delete :destroy, id: budget_item, format: :json
          result = JSON.parse(response.body)
          expect(result).to include('error')
          expect(result).to have(1).item
        end
      end
    end
  end
end
