require 'spec_helper'

describe LotsController do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:account) { FactoryGirl.create(:commodities_account, entity: entity) }
  let (:other_account) { FactoryGirl.create(:commodities_account, entity: entity) }
  let (:commodity) { FactoryGirl.create(:commodity, entity: entity, symbol: 'KSS') }
  let (:commodity_account) { Account.find_by_name(commodity.symbol) }
  let!(:other_commodity) { FactoryGirl.create(:commodity, entity: entity, symbol: 'KSX') }
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
  let (:lot) { commodity.lots.first }
  let (:transfer_attributes) do
    { target_account_id: other_account.id }
  end
  let (:exchange_attributes) do
    { commodity_id: other_commodity.id }
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

      describe 'get :new_transfer' do
        it 'should be successful' do
          get :new_transfer, id: lot
          expect(response).to be_success
        end
      end

      describe 'put :transfer' do
        it 'should redirect to the lot index page for the original account' do
          put :transfer, id: lot, transfer: transfer_attributes, account_id: account
          expect(response).to redirect_to account_lots_path(commodity_account)
        end

        it 'should add the lot to the specified account' do
          put :transfer, id: lot, transfer: transfer_attributes
          expect(other_account.children.find_by_name('KSS')).to have(1).lot
        end

        it 'should remove the lot from the current account' do
          commodity_account = account.children.find_by_name('KSS')
          expect do
            put :transfer, id: lot, transfer: transfer_attributes
          end.to change(commodity_account.lots, :count).by(-1)
        end
      end

      describe 'get :new_exchange' do
        it 'should be successful' do
          get :new_exchange, id: lot
          expect(response).to be_success
        end
      end

      describe 'put :exchange' do
        it 'should redirec to the lot index page for the original account' do
          put :exchange, id: lot, exchange: exchange_attributes
          expect(response).to redirect_to account_lots_path(commodity_account)
        end

        it 'should remove the shares of the original commodity' do
          original_lot = commodity.lots.first
          expect do
            put :exchange, id: lot, exchange: exchange_attributes
            original_lot.reload
          end.to change(original_lot, :shares_owned).by(-100)
        end

        it 'should add shares of the selected commodity' do
          put :exchange, id: lot, exchange: exchange_attributes
          expect(other_commodity).to have(1).lot
          expect(other_commodity.lots.first.shares_owned).to eq(100)
        end

        it 'should not change the cost basis of the lots' do
          original_cost_basis = commodity.lots.first.cost
          put :exchange, id: lot, exchange: exchange_attributes
          expect(other_commodity.lots.first.cost).to eq(original_cost_basis)
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

      describe 'get :new_transfer' do
        it 'should redirect to the user home page' do
          get :new_transfer, id: lot
          expect(response).to redirect_to home_path
        end
      end

      describe 'put :transfer' do
        it 'should redirect to the user home page' do
          put :transfer, id: lot, transfer: transfer_attributes
          expect(response).to redirect_to home_path
        end

        it 'should not add the lot to the specified account' do
          expect do
            put :transfer, id: lot, transfer: transfer_attributes
          end.not_to change(other_account.lots, :count)
        end
      end

      describe 'get :new_exchange' do
        it 'should redirect to the user home page' do
          get :new_exchange, id: lot
          expect(response).to redirect_to(home_path)
        end
      end

      describe 'put :exchange' do
        it 'should redirect to the user home page' do
          put :exchange, id: lot, exchange: exchange_attributes
          expect(response).to redirect_to(home_path)
        end

        it 'should not remove the shares of the original commodity' do
          put :exchange, id: lot, exchange: exchange_attributes
          expect(commodity.lots(true).count).to eq(2)
        end

        it 'should not add shares of the selected commodity' do
          put :exchange, id: lot, exchange: exchange_attributes
          expect(other_commodity.lots(true).count).to eq(0)
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

    describe 'get :new_transfer' do
      it 'should redirect to the sign in page' do
        get :new_transfer, id: lot
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'put :transfer' do
      it 'should redirect to the sign in page' do
        put :transfer, id: lot, transfer: transfer_attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'should not add the lot to the specified account' do
        expect do
          put :transfer, id: lot, transfer: transfer_attributes
        end.not_to change(other_account.lots, :count)
      end
    end

    describe 'get :new_exchange' do
      it 'should redirect to the sign in page' do
        get :new_exchange, id: lot
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'put :exchange' do
      it 'should redirect to the sign in page' do
        put :exchange, id: lot, exchange: exchange_attributes
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'should not remove the shares of the original commodity' do
        put :exchange, id: lot, exchange: exchange_attributes
        expect(commodity.lots(true).count).to eq(2)
      end

      it 'should not add shares of the selected commodity' do
        put :exchange, id: lot, exchange: exchange_attributes
        expect(other_commodity.lots(true).count).to eq(0)
      end
    end
  end
end
