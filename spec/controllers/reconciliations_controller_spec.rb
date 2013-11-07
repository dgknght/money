require 'spec_helper'

describe ReconciliationsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'Salary') }
  let (:transaction) do
    entity.transactions.create!(transaction_date: '2013-01-01', description: 'My job', items_attributes: [
      { account_id: salary.id, action: TransactionItem.credit, amount: 1_000 },
      { account_id: checking.id, action: TransactionItem.debit, amount: 1_000 }
    ]);
  end
  let (:attributes) do
    {
      account_id: checking.id,
      reconciliation_date: '2013-01-31',
      closing_balance: 1_000,
      transactions: [transaction]
    }
  end
  context 'for an authenticated user' do
    
    context 'to which the entity belongs' do
      before(:each) { sign_in entity.user }
      
      describe "get :new" do
        it 'should be successful' do
          get :new, account_id: checking
          response.should be_success
        end
      end

      describe "post :create" do
        it 'should create the reconciliation' do
          lambda do
            post :create, account_id: checking, reconciliation: attributes
          end.should change(Reconciliation, :count).by(1)
        end
        
        it 'should redirect to the reconciliation detail page' do
          post :create, account_id: checking, reconciliation: attributes
          response.should redirect_to reconciliation_path(Reconciliation.last)
        end
        
        context 'in json' do
          it 'should be successful' do
            post :create, account_id: checking, reconciliation: attributes, format: :json
            response.should be_success
          end
          
          it 'should create the reconciliation' do
            lambda do
              post :create, account_id: checking, reconciliation: attributes, format: :json
            end.should change(Reconciliation, :count).by(1)
          end
        end
      end
    end
    
    context 'to which the entity does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }
      
      describe "get :new" do
        it "should redirect to the user's home page" do
          get :new, account_id: checking
          response.should redirect_to home_path
        end
      end

      describe "post :create" do
        it "should redirect to the user's home page"
        it 'should not create the reconciliation'
        context 'in json' do
          it 'should return "resource not found"'
          it 'should not create the reconciliation'
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe "get :new" do
      it 'should redirect to the sign in page' do
        get :new, account_id: checking
        response.should redirect_to new_user_session_path
      end
    end

    describe "post :create" do
      it 'should redirect to the sign in page'
      it 'should not create a reconciliation'
      context 'in json' do
        it 'should return "access denied"'
        it 'should not create the reconciliation'
      end
    end
  end
end
