require 'spec_helper'

describe LotsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:account) { FactoryGirl.create(:commodities_account, entity: entity) }
  let (:commodity) { FactoryGirl.create(:commodity, entity: entity) }
  let (:commodity_account) { Account.find_by_name(commodity.symbol) }
  let!(:transaction1) do
    CommodityTransactionCreator.new(account: account,
                                    transaction_date: '2014-01-01',
                                    action: CommodityTransactionCreator.buy,
                                    symbol: commodity.symbol,
                                    shares: 100,
                                    value: 1_200).create!
  end
  let!(:transaction2) do
    CommodityTransactionCreator.new(account: account,
                                    transaction_date: '2014-02-01',
                                    action: CommodityTransactionCreator.buy,
                                    symbol: commodity.symbol,
                                    shares: 100,
                                    value: 1_300).create!
  end

  context 'for an authenticated user' do
    context 'that owns the entity' do
      before(:each) { sign_in entity.user }

      describe 'get :index' do
        it 'should be successful' do
          get :index, account_id: commodity_account
          expect(response).to be_success
        end

        context 'in json' do
          it 'should be successful' do
            get :index, account_id: commodity_account, format: :json
            expect(response).to be_success
          end

          it 'should return the specified lot records' do
            get :index, account_id: commodity_account, format: :json
            expect(response.body).to eq(commodity_account.lots.to_json)
          end
        end
      end
    end

    context 'that does not own the entity' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :index' do
        it 'should redirect to the user home page' do
          get :index, account_id: commodity_account
          expect(response).to redirect_to home_path
        end

        context 'in json' do
          it 'should return "resource not found"' do
            get :index, account_id: commodity_account, format: :json
            expect(response).to be_not_found
          end

          it 'should not return any data' do
            get :index, account_id: commodity_account, format: :json
            expect(response.body).to eq([].to_json)
          end
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'should redirect to the sign in page' do
        get :index, account_id: commodity_account
        expect(response).to redirect_to new_user_session_path
      end

      context 'in json' do
        it 'should return "access denied"' do
          get :index, account_id: commodity_account, format: :json
          expect(response.response_code).to eq(401)
        end

        it 'should return an error' do
          get :index, account_id: commodity_account, format: :json
          response_hash = JSON.parse(response.body)
          expect(response_hash.keys).to have(1).item
          expect(response_hash).to have_key('error')
        end
      end
    end
  end
end
