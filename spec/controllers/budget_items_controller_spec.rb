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
        it "should be successful" do
          get :index, budget_id: budget
          response.should be_success
        end
        
        context 'in json' do
          it 'should be successful' do
            get :index, budget_id: budget, format: :json
            response.should be_success
          end
          
          it 'should return the budget item list' do
            get :index, budget_id: budget, format: :json
            response.body.should json_match [budget_item]
          end
        end
      end

      describe "get :show" do
        it "should be successful" do
          get :show, id: budget_item
          response.should be_success
        end
        
        context 'in json' do
          it 'should be successful' do
            get :show, id: budget_item, format: :json
            response.should be_success
          end
          
          it 'should return the budget item' do
            get :show, id: budget_item, format: :json
            response.body.should json_match budget_item
          end
        end
      end

      describe "get :new" do
        it "should be successful" do
          get :new, budget_id: budget
          response.should be_success
        end
      end

      describe "post :create" do
        it "should redirect to the budget item detail page" do
          post :create, budget_id: budget, budget_item: attributes, distributor: distributor
          response.should redirect_to budget_budget_items_path(budget)
        end
        
        it 'should create a new budget item' do
          lambda do
            post :create, budget_id: budget, budget_item: attributes, distributor: distributor
          end.should change(BudgetItem, :count).by(1)
        end
        
        it 'should create the correct budget amounts for each period' do
          post :create, budget_id: budget, budget_item: attributes, distributor: distributor
          budget_item = BudgetItem.last
          budget_item.periods.map{ |p| p.budget_amount }.should == (1..12).map{ |i| 100}
        end
        
        context 'in json' do
          it 'should be successful' do
            post :create, budget_id: budget, budget_item: attributes, distributor: distributor, format: :json
            response.should be_success
          end
          
          it 'should create a new budget item' do
            lambda do
              post :create, budget_id: budget, budget_item: attributes, distributor: distributor, format: :json
            end.should change(BudgetItem, :count).by(1)
          end
          
          it 'should return the new budget item' do
            post :create, budget_id: budget, budget_item: attributes, distributor: distributor, format: :json
            result = JSON.parse(response.body)
            attributes.each { |k, v| result[k.to_s].should == v }
          end
        end
      end

      describe "get :edit" do
        it "should be successful" do
          get :edit, id: budget_item
          response.should be_success
        end
      end

      describe "put :update" do
        it "should redirect to the budget item index page" do
          put :update, id: budget_item, budget_item: attributes, distributor: distributor
          response.should redirect_to budget_budget_items_path(budget_item.budget)
        end
        
        it 'should update the budget item' do
          lambda do
            put :update, id: budget_item, budget_item: attributes, distributor: distributor
            budget_item.reload
          end.should change(budget_item, :account_id).to(account.id)
        end
        
        context 'in json' do
          it 'should be successful' do
            put :update, id: budget_item, budget_item: attributes, distributor: distributor, format: :json
            response.should be_success
          end
          
          it 'should update the specified budget item' do
            lambda do
              put :update, id: budget_item, budget_item: attributes, distributor: distributor, format: :json
              budget_item.reload
            end.should change(budget_item, :account_id).to(account.id)
          end
          
          it 'should not return any data' do
            put :update, id: budget_item, budget_item: attributes, distributor: distributor, format: :json
            response.body.should be_blank
          end
        end
      end

      describe "delete :destroy" do
        it "should redirect to the budget item index page" do
          delete :destroy, id: budget_item
          response.should redirect_to budget_budget_items_path(budget)
        end
        
        it 'should delete the budget item' do
          lambda do
            delete :destroy, id: budget_item
          end.should change(BudgetItem, :count).by(-1)
        end
        
        context 'in json' do
          it 'should be successful' do
            delete :destroy, id: budget_item, format: :json
            response.should be_success
          end
          
          it 'should delete the specified budget item' do
            lambda do
              delete :destroy, id: budget_item, format: :json
            end.should change(BudgetItem, :count).by(-1)
          end
        end
      end
    end
    
    context "that does not own the entity" do
      let(:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }
      
      describe "get :index" do
        it 'should redirect to the user home page' do
          get :index, budget_id: budget
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            get :index, budget_id: budget, format: :json
            response.response_code.should == 404
          end
          
          it 'should not return any data' do
            get :index, budget_id: budget, format: :json
            response.body.should == [].to_json
          end
        end
      end

      describe "get :show" do
        it 'should redirect to the user home page' do
          get :show, id: budget_item
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            get :show, id: budget_item, format: :json
            response.response_code.should == 404
          end
          
          it 'should not return any data' do
            get :show, id: budget_item, format: :json
            response.body.should == [].to_json
          end
        end
      end

      describe "get :new" do
        it 'should redirect to the user home page' do
          get :new, budget_id: budget
          response.should redirect_to home_path
        end
      end

      describe "post :create" do
        it 'should redirect to the user home page' do
          post :create, budget_id: budget, budget_item: attributes
          response.should redirect_to home_path
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            post :create, budget_id: budget, budget_item: attributes, format: :json
            response.response_code.should == 404
          end
          
          it 'should not create a new budget item' do
            lambda do
              post :create, budget_id: budget, budget_item: attributes, format: :json
            end.should_not change(BudgetItem, :count)
          end
          
          it 'should not return any data' do
            post :create, budget_id: budget, budget_item: attributes, format: :json
            response.body.should == [].to_json
          end
        end
      end

      describe "get :edit" do
        it 'should redirect to the user home page' do
          get :edit, id: budget_item
          response.should redirect_to home_path
        end
      end

      describe "put :update" do
        it 'should redirect to the user home page' do
          put :update, id: budget_item, budget_item: attributes
          response.should redirect_to home_path
        end
        
        it 'should not update the item' do
          lambda do
            put :update, id: budget_item, budget_item: attributes
            budget_item.reload
          end.should_not change(budget_item, :account_id)
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            put :update, id: budget_item, budget_item: attributes, format: :json
            response.response_code.should == 404
          end
          
          it 'should not update the specified budget item' do
            lambda do
              put :update, id: budget_item, budget_item: attributes, format: :json
              budget_item.reload
            end.should_not change(budget_item, :account_id)
          end
          
          it 'should not return any data' do
            put :update, id: budget_item, budget_item: attributes, format: :json
            response.body.should == [].to_json
          end
        end
      end

      describe "delete :destroy" do
        it 'should redirect to the user home page' do
          delete :destroy, id: budget_item
          response.should redirect_to home_path
        end
        
        it 'should not delete the budget item' do
          lambda do
            delete :destroy, id: budget_item
          end.should_not change(BudgetItem, :count)
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            delete :destroy, id: budget_item, format: :json
            response.response_code.should == 404
          end
          
          it 'should not delete the item' do
            lambda do
              delete :destroy, id: budget_item, format: :json
            end.should_not change(BudgetItem, :count)
          end
          
          it 'should not return any data' do
            delete :destroy, id: budget_item, format: :json
            response.body.should == [].to_json
          end
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
      it 'should redirect to the sign in page' do
        get :new, budget_id: budget
        response.should redirect_to new_user_session_path
      end
    end

    describe "post :create" do
      it 'should redirect to the sign in page' do
        post :create, budget_id: budget, budget_item: attributes
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          post :create, budget_id: budget, budget_item: attributes, format: :json
          response.response_code.should == 401
        end
        
        it 'should not create a new budget item' do
          lambda do
            post :create, budget_id: budget, budget_item: attributes, format: :json
          end.should_not change(BudgetItem, :count)
        end
        
        it 'should return an error message' do
          post :create, budget_id: budget, budget_item: attributes, format: :json
          result = JSON.parse(response.body)
          result.should include('error')
          result.should have(1).item
        end
      end
    end

    describe "get :edit" do
      it 'should redirect to the sign in page' do
        get :edit, id: budget_item
        response.should redirect_to new_user_session_path
      end
    end

    describe "put :update" do
      it 'should redirect to the sign in page' do
        put :update, id: budget_item, budget_item: attributes
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          put :update, id: budget_item, budget_item: attributes, format: :json
          response.response_code.should == 401
        end
        
        it 'should not update the specified budget item' do
          lambda do
            put :update, id: budget_item, budget_item: attributes, format: :json
            budget_item.reload
          end.should_not change(budget_item, :account_id)
        end
        
        it 'should return an error message' do
          put :update, id: budget_item, budget_item: attributes, format: :json
          result = JSON.parse(response.body)
          result.should include('error')
          result.should have(1).item
        end
      end
    end

    describe "delete :destroy" do
      it 'should redirect to the sign in page' do
        delete :destroy, id: budget_item
        response.should redirect_to new_user_session_path
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          delete :destroy, id: budget_item, format: :json
          response.response_code.should == 401
        end
        
        it 'should not delete the item' do
          lambda do
            delete :destroy, id: budget_item, format: :json
          end.should_not change(BudgetItem, :count)
        end
        
        it 'should return an error message' do
          delete :destroy, id: budget_item, format: :json
          result = JSON.parse(response.body)
          result.should include('error')
          result.should have(1).item
        end
      end
    end
  end
end
