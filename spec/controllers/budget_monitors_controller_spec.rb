require 'spec_helper'

describe BudgetMonitorsController do
  let (:entity) { FactoryGirl.create(:entity) }

  context 'for an authenticated user' do
    context 'that owns the entity' do
      before(:each) { sign_in entity.user}

      describe 'get :index' do
        it 'should be successful ' do
          get :index, entity_id: entity
          expect(response).to be_success
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
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index, entity_id: entity
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
