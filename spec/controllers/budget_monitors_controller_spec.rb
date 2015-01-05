require 'spec_helper'

describe BudgetMonitorsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:account) { FactoryGirl.create(:account, entity: entity) }
  let (:attributes) do
    {
      account_id: account.id
    }
  end

  context 'for an authenticated user' do
    context 'that owns the entity' do
      before(:each) { sign_in entity.user}

      describe 'get :index' do
        it 'should be successful ' do
          get :index, entity_id: entity
          expect(response).to be_success
        end
      end

      describe 'get :new' do
        it 'should be successful' do
          get :new, entity_id: entity
          expect(response).to be_success
        end
      end

      describe 'post :create' do
        it 'should redirect to the budget monitors page' do
          post :create, entity_id: entity, budget_monitor: attributes
        end

        it 'should create the budget monitor' do
          expect do
            post :create, entity_id: entity, budget_monitor: attributes
          end.to change(BudgetMonitor, :count).by(1)
        end
      end
    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :index' do
        it 'should redirect to the user home page' do
          get :index, entity_id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe 'get :new' do
        it 'should redirect to the user home page' do
          get :new, entity_id: entity
          expect(response).to redirect_to home_path
        end
      end

      describe 'post :create' do
        it 'should redirect to the user home page' do
          post :create, entity_id: entity, budget_monitor: attributes
          expect(response).to redirect_to home_path
        end

        it 'should not create the budget monitor' do
          expect do
            post :create, entity_id: entity, budget_monitor: attributes
          end.not_to change(BudgetMonitor, :count)
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index, entity_id: entity
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'get :new' do
      it 'should redirect to the sign in page' do
        get :new, entity_id: entity
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'post :create' do
      it 'should redirect to the sign in page' do
        post :create, entity_id: entity, budget_monitor: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'should not create the budget monitor' do
        expect do
          post :create, entity_id: entity, budget_monitor: attributes
        end.not_to change(BudgetMonitor, :count)
      end
    end
  end
end
