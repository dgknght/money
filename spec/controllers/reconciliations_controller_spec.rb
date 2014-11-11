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
        it 'should be successful' do
          get :new, account_id: checking
          response.should be_success
        end

        context 'in JSON' do
          it 'should be successful' do
            get :new, account_id: checking, format: :json
            response.should be_success
          end

          it 'should return the new reconciliation information' do
            Timecop.freeze(Time.parse('2014-02-27 12:00:00 UTC')) do
              get :new, account_id: checking, format: :json
              content = JSON.parse(response.body)
              content.should == {
                'id' => nil,
                'account_id' => checking.id,
                'reconciliation_date' => '2014-02-27',
                'closing_balance' => nil,
                'created_at' => nil,
                'updated_at' => nil,
                'previous_reconciliation_date' => nil,
                'previous_balance' => 0
              }
            end
          end
        end
      end

      describe "post :create" do
        it 'should create the reconciliation' do
          lambda do
            post :create, account_id: checking, reconciliation: attributes
          end.should change(Reconciliation, :count).by(1)
        end
        
        it 'should redirect to the account transaction item index page' do
          post :create, account_id: checking, reconciliation: attributes
          response.should redirect_to account_transaction_items_path(entity)
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

        context 'in JSON' do
          it 'should return "resource not found"' do
            get :new, account_id: checking, format: :json
            response.response_code.should == 404
          end

          it 'should not return any data' do
            get :new, account_id: checking, format: :json
            response.body.should == [].to_json
          end
        end
      end

      describe "post :create" do
        it "should redirect to the user's home page" do
          post :create, account_id: checking, reconciliation: attributes
          response.should redirect_to home_path
        end
        
        it 'should not create the reconciliation' do
          lambda do
            post :create, account_id: checking, reconciliation: attributes
          end.should_not change(Reconciliation, :count)
        end
        
        context 'in json' do
          it 'should return "resource not found"' do
            post :create, account_id: checking, reconciliation: attributes, format: :json
            response.response_code.should == 404
          end
        
          it 'should not create the reconciliation' do
            lambda do
              post :create, account_id: checking, reconciliation: attributes
            end.should_not change(Reconciliation, :count)
          end
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

        context 'in JSON' do
          it 'should return "access denied"' do
            get :new, account_id: checking, format: :json
            response.response_code.should == 401
          end

          it 'should return an error' do
            get :new, account_id: checking, format: :json
            content = JSON.parse(response.body)
            content.delete('error').should_not be_nil
            content.should be_empty
          end
        end
    end

    describe "post :create" do
      it 'should redirect to the sign in page' do
        post :create, account_id: checking, reconciliation: attributes
        response.should redirect_to new_user_session_path
      end
      
      it 'should not create a reconciliation' do
        lambda do
          post :create, account_id: checking, reconciliation: attributes
        end.should_not change(Reconciliation, :count)
      end
      
      context 'in json' do
        it 'should return "access denied"' do
          post :create, account_id: checking, reconciliation: attributes, format: :json
          response.response_code.should == 401
        end
        
        it 'should not create the reconciliation' do
          lambda do
            post :create, account_id: checking, reconciliation: attributes, format: :json
          end.should_not change(Reconciliation, :count)
        end
      end
    end
  end
end
