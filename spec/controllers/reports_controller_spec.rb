require 'spec_helper'

describe ReportsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:budget) { FactoryGirl.create(:budget, entity: entity) }
  
  context 'for an authenticated user' do
    context 'to which the entity belongs' do
    
      before(:each) { sign_in entity.user }
      
      describe "get :index" do
        it 'is successful' do
          get :index, id: entity
          expect(response).to be_success
        end
      end
      
      describe "get :balance_sheet" do
        it 'is successful' do
          get :balance_sheet, id: entity
          expect(response).to be_success
        end
      end

      describe "get :income_statement" do
        it 'is successful' do
          get :income_statement, id: entity
          expect(response).to be_success
        end
      end

      describe "get :budget" do
        it 'is successful' do
          get :budget, id: entity, filter: { budget_id: budget.id }
          expect(response).to be_success
        end
      end
    end

    context 'to which the entity does not belong' do
      let(:other_user) { FactoryGirl.create(:user) }
      
      before(:each) { sign_in other_user }
      
      describe "get :index" do
        it 'redirects to the user home page' do
          get :index, id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe "get :balance_sheet" do
        it 'redirects to the user home page' do
          get :balance_sheet, id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe "get :income_statement" do
        it 'redirects to the user home page' do
          get :income_statement, id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe "get :budget" do
        it 'is successful' do
          get :budget, id: entity, filter: { budget_id: budget.id }
          expect(response).to redirect_to home_path
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe "get :index" do
      it 'redirects to the sign in page' do
          get :index, id: entity
          expect(response).to redirect_to new_user_session_path
        end
    end

    describe "get :balance_sheet" do
      it 'redirects to the sign in page' do
          get :balance_sheet, id: entity
          expect(response).to redirect_to new_user_session_path
        end
    end

    describe "get :income_statement" do
      it 'redirects to the sign in page' do
        get :income_statement, id: entity
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "get :budget" do
      it 'is successful' do
        get :budget, id: entity, filter: { budget_id: budget.id }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
