require 'spec_helper'

describe TransactionDestroyer do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:ira) { FactoryGirl.create(:commodities_account, entity: entity) }
  let!(:st_gains) { FactoryGirl.create(:income_account, entity: entity, name: 'Short-term capital gains') }
  let!(:lt_gains) { FactoryGirl.create(:income_account, entity: entity, name: 'Long-term capital gains') }
  let!(:commodity) { FactoryGirl.create(:commodity, symbol: 'KSS', entity: entity) }
  let (:commodity_account) { Account.find_by_name('KSS') }
  let!(:regular_transaction) { FactoryGirl.create(:transaction, entity: entity) }
  let!(:commodity_purchase_transaction) do
    CommodityTransactionCreator.new(
      account: ira,
      action: CommodityTransactionCreator.buy,
      symbol: 'KSS',
      shares: 100,
      value: 1_000
    ).create!
  end

  describe '#destroy' do
    context 'when successful' do
      it 'should destroy the transaction' do
        expect do
          TransactionDestroyer.new(regular_transaction).destroy
        end.to change(Transaction, :count).by(-1)
      end

      it 'should return true on success' do
        result = TransactionDestroyer.new(regular_transaction).destroy
        expect(result).to be true
      end

      context 'for lot-creating transactions' do
        it 'should destroy the associated lot' do
          expect do
            TransactionDestroyer.new(commodity_purchase_transaction).destroy
          end.to change(Lot, :count).by(-1)
        end

        it 'should destroy the associating lot-transaction record' do
          expect do
            TransactionDestroyer.new(commodity_purchase_transaction).destroy
          end.to change(LotTransaction, :count).by(-1)
        end
      end

      context 'for lot-depleting transactions' do
        let!(:commodity_sale_transaction) do
          CommodityTransactionCreator.new(
            account: ira,
            action: CommodityTransactionCreator.sell,
            symbol: 'KSS',
            shares: 50,
            value: 600
          ).create!
        end

        it 'should restore the shares to the lot' do
          lot = commodity_account.lots.first
          expect do
            TransactionDestroyer.new(commodity_sale_transaction).destroy
            lot.reload
          end.to change(lot, :shares_owned).from(50).to(100)
        end

        it 'should not destroy the lot' do
          expect do
            TransactionDestroyer.new(commodity_sale_transaction).destroy
          end.not_to change(Lot, :count)
        end

        it 'should destroy the lot-transaction link' do
          expect do
            TransactionDestroyer.new(commodity_sale_transaction).destroy
          end.to change(LotTransaction, :count).by(-1)
        end
      end
    end

    context 'when unsuccessful' do
      let!(:commodity_sale_transaction) do
        CommodityTransactionCreator.new(
          account: ira,
          action: CommodityTransactionCreator.sell,
          symbol: 'KSS',
          shares: 50,
          value: 600
        ).create!
      end
      before(:each) { LotTransaction.any_instance.stub(:destroy).and_raise('Testing, 1, 2, 3') }
      it 'should not raise an exception' do
        expect do
          TransactionDestroyer.new(commodity_sale_transaction).destroy
        end.not_to raise_error
      end

      it 'should return false' do
          destroyer = TransactionDestroyer.new(commodity_sale_transaction)
          expect(destroyer.destroy).to be false
      end

      it 'should not destroy the transaction' do
        expect do
          TransactionDestroyer.new(commodity_sale_transaction).destroy
        end.not_to change(Transaction, :count)
      end

      context 'for commodity purchase transactions' do
        it 'should not destroy the associated lot' do
          expect do
            TransactionDestroyer.new(commodity_purchase_transaction).destroy
          end.not_to change(Lot, :count)
        end
      end

      context 'for commodity sale transactions' do
        it 'should not change the balance of shares owned for the lot' do
          lot = commodity_sale_transaction.lot_transactions.first.lot
          expect do
            TransactionDestroyer.new(commodity_sale_transaction).destroy
            lot.reload
          end.not_to change(lot, :shares_owned)
        end

        it 'should not destroy the lot-transaction link' do
          expect do
            TransactionDestroyer.new(commodity_sale_transaction).destroy
          end.not_to change(LotTransaction, :count)
        end
      end
    end

    context 'for a buy transaction that has associated sell transactions' do
      let!(:commodity_sale_transaction) do
        CommodityTransactionCreator.new(
          account: ira,
          action: CommodityTransactionCreator.sell,
          symbol: 'KSS',
          shares: 50,
          value: 600
        ).create!
      end
      describe '#destroy' do
        it 'should return false' do
          destroyer = TransactionDestroyer.new(commodity_purchase_transaction)
          expect(destroyer.destroy).to be false
        end
      end

      describe '#error' do
        it 'should indicate why the transaction cannot be deleted' do
          destroyer = TransactionDestroyer.new(commodity_purchase_transaction)
          destroyer.destroy
          expect(destroyer.error).to eq('Cannot delete commodity purchase transactions with associated sale transactions.')
        end
      end
    end
  end

  describe '#notice' do
    context 'when unsuccessful' do
      before(:each) { LotTransaction.any_instance.stub(:destroy).and_raise('Testing, 1, 2, 3') }
      it 'should be blank' do
        destroyer = TransactionDestroyer.new(commodity_purchase_transaction)
        destroyer.destroy
        expect(destroyer.notice).to be_blank
      end
    end

    context 'when successful' do
      context 'for transactions associated with commodities' do
        it 'should indicate that the commodity transaction was removed' do
          destroyer = TransactionDestroyer.new(commodity_purchase_transaction)
          destroyer.destroy
          expect(destroyer.notice).to eq("The commodity transaction was removed successfully.")
        end
      end
      context 'for transactions that are not associated with commodities' do
        it 'should indicate that the transaction was removed' do
          destroyer = TransactionDestroyer.new(regular_transaction)
          destroyer.destroy
          expect(destroyer.notice).to eq("The transaction was removed successfully.")
        end
      end
    end
  end

  describe '#error' do
    context 'when unsuccessful' do
      before(:each) { LotTransaction.any_instance.stub(:destroy).and_raise('Testing 1, 2, 3') }
      it 'should contain a description of the error' do
          destroyer = TransactionDestroyer.new(commodity_purchase_transaction)
          destroyer.destroy
          expect(destroyer.error).to eq('Testing 1, 2, 3')
      end
    end
    context 'when successful' do
      it 'should be blank' do
          destroyer = TransactionDestroyer.new(regular_transaction)
          destroyer.destroy
          expect(destroyer.error).to be_blank
      end
    end
  end
end
