require 'spec_helper'

describe TransactionDestroyer do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:ira) { FactoryGirl.create(:commodity_account, entity: entity) }
  let!(:st_gains) { FactoryGirl.create(:income_account, entity: entity) }
  let!(:commodity) { FactoryGirl.create(:commodity, symbol: 'KSS', entity: entity) }
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
        expect(result).to be_true
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
        it 'should restore the shares to the lot'
      end
    end

    context 'when unsuccessful' do
      it 'should return false'
      it 'should not destroy the transaction or change any lots'
    end
  end

  describe '#notice' do
    context 'when unsuccessful' do
      it 'should be blank'
    end
    context 'when successful' do
      context 'for transactions associated with commodities' do
        it 'should indicate that the commodity transaction was removed'
      end
      context 'for transactions that are not associated with commodities' do
        it 'should indicate that the transaction was removed'
      end
    end
  end

  describe '#error' do
    context 'when unsuccessful' do
      it 'should contain a description of the error'
    end
    context 'when successful' do
      it 'should be blank'
    end
  end
end
