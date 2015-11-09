require 'spec_helper'

describe ReconciliationsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'Salary') }
  let (:transaction) { FactoryGirl.create(:transaction, entity: entity, credit_account: salary, debit_account: checking, amount: 1_000) }
  let (:attributes) do
    {
      account_id: checking.id,
      reconciliation_date: '2013-01-31',
      closing_balance: 1_000,
      items_attributes: [ 
        { transaction_item_id: transaction.items.select{ |i| i.account.id == checking.id }.first.id }
      ]
    }
  end
  context 'for an authenticated user' do
    
    context 'to which the entity belongs' do
      before(:each) { sign_in entity.user }
      
      describe "get :new" do
        it 'is successful' do
          get :new, account_id: checking
          expect(response).to be_success
        end

        context 'in JSON' do
          it 'is successful' do
            get :new, account_id: checking, format: :json
            expect(response).to be_success
          end

          it 'returns the new reconciliation information' do
            Timecop.freeze(Time.parse('2014-02-27 12:00:00 UTC')) do
              get :new, account_id: checking, format: :json
              content = JSON.parse(response.body)
              expect(content).to eq({
                'id' => nil,
                'account_id' => checking.id,
                'reconciliation_date' => '2014-02-27',
                'closing_balance' => nil,
                'created_at' => nil,
                'updated_at' => nil,
                'previous_reconciliation_date' => nil,
                'previous_balance' => 0
              })
            end
          end
        end
      end

      describe "post :create" do
        it 'creates the reconciliation' do
          expect do
            post :create, account_id: checking, reconciliation: attributes
          end.to change(Reconciliation, :count).by(1)
        end
        
        it 'redirects to the account transaction item index page' do
          post :create, account_id: checking, reconciliation: attributes
          expect(response).to redirect_to account_transaction_items_path(entity)
        end
        
        context 'in json' do
          it 'is successful' do
            post :create, account_id: checking, reconciliation: attributes, format: :json
            expect(response).to be_success
          end
          
          it 'creates the reconciliation' do
            expect do
              post :create, account_id: checking, reconciliation: attributes, format: :json
            end.to change(Reconciliation, :count).by(1)
          end
        end
      end
    end
    
    context 'to which the entity does not belong' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }
      
      describe "get :new" do
        it "redirects to the user's home page" do
          get :new, account_id: checking
          expect(response).to redirect_to home_path
        end

        context 'in JSON' do
          it 'returns "resource not found"' do
            get :new, account_id: checking, format: :json
            expect(response.response_code).to eq(404)
          end

          it 'does not return any data' do
            get :new, account_id: checking, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end

      describe "post :create" do
        it "redirects to the user's home page" do
          post :create, account_id: checking, reconciliation: attributes
          expect(response).to redirect_to home_path
        end
        
        it 'does not create the reconciliation' do
          expect do
            post :create, account_id: checking, reconciliation: attributes
          end.to_not change(Reconciliation, :count)
        end
        
        context 'in json' do
          it 'returns "resource not found"' do
            post :create, account_id: checking, reconciliation: attributes, format: :json
            expect(response.response_code).to eq(404)
          end
        
          it 'does not create the reconciliation' do
            expect do
              post :create, account_id: checking, reconciliation: attributes
            end.to_not change(Reconciliation, :count)
          end
        end
      end
    end
  end
  
  context 'for an unauthenticated user' do
    describe "get :new" do
      it 'redirects to the sign in page' do
        get :new, account_id: checking
        expect(response).to redirect_to new_user_session_path
      end

        context 'in JSON' do
          it 'returns "access denied"' do
            get :new, account_id: checking, format: :json
            expect(response.response_code).to eq(401)
          end

          it 'returns an error' do
            get :new, account_id: checking, format: :json
            content = JSON.parse(response.body)
            expect(content.delete('error')).to_not be_nil
            expect(content).to be_empty
          end
        end
    end

    describe "post :create" do
      it 'redirects to the sign in page' do
        post :create, account_id: checking, reconciliation: attributes
        expect(response).to redirect_to new_user_session_path
      end
      
      it 'does not create a reconciliation' do
        expect do
          post :create, account_id: checking, reconciliation: attributes
        end.to_not change(Reconciliation, :count)
      end
      
      context 'in json' do
        it 'returns "access denied"' do
          post :create, account_id: checking, reconciliation: attributes, format: :json
          expect(response.response_code).to eq(401)
        end
        
        it 'does not create the reconciliation' do
          expect do
            post :create, account_id: checking, reconciliation: attributes, format: :json
          end.to_not change(Reconciliation, :count)
        end
      end
    end
  end
end
