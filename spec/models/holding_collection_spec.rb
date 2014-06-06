require 'spec_helper'

describe HoldingCollection do
  let (:kss) { FactoryGirl.create(:commodity, symbol: 'KSS', name: 'Knight Software Services') }
  let (:msft) { FactoryGirl.create(:commodity, symbol: 'MSFT', name: 'Microsoft') }
  let!(:kss_price) { FactoryGirl.create(:price, commodity: kss, price: 15) }
  let!(:msft_price) { FactoryGirl.create(:price, commodity: msft, price: 24) }
  let (:kss_lot1) { FactoryGirl.create(:lot, commodity: kss, shares_owned: 100, price: 10) }
  let (:kss_lot2) { FactoryGirl.create(:lot, commodity: kss, shares_owned: 200, price: 12) }
  let (:msft_lot1) { FactoryGirl.create(:lot, commodity: msft, shares_owned: 10, price: 25) }

  describe '#<<' do
    it 'should add a lot to the list of holdings' do
      collection = HoldingCollection.new
      expect do
        collection << kss_lot1
      end.to change(collection, :count).by(1)
    end

    it 'should aggregate holdings by commodity' do
      collection = HoldingCollection.new kss_lot1
      expect do
        collection << kss_lot2
      end.not_to change(collection, :count)

      expect do
        collection << msft_lot1
      end.to change(collection, :count).by(1)
    end
  end

  describe '#total_current_value' do
    it 'should summarize the current value of all the holdings' do
      collection = HoldingCollection.new kss_lot1
      expect(collection.total_current_value).to eq(1_500)

      expect do
        collection << kss_lot2
      end.to change(collection, :total_current_value).from(1_500).to(4_500)

      expect do
        collection << msft_lot1
      end.to change(collection, :total_current_value).from(4_500).to(4_740)
    end
  end

  describe '#total_cost' do
    it 'should summarize the cost of all the holdings' do
      collection = HoldingCollection.new kss_lot1
      expect(collection.total_cost).to eq(1_000)

      expect do
        collection << kss_lot2
      end.to change(collection, :total_cost).from(1_000).to(3_400)

      expect do
        collection << msft_lot1
      end.to change(collection, :total_cost).from(3_400).to(3_650)
    end
  end

  describe '#total_gain_loss' do
    it 'should summarize the gain/loss of all the holdings' do
      collection = HoldingCollection.new kss_lot1
      expect(collection.total_gain_loss).to eq(500)

      collection << kss_lot2
      expect(collection.total_gain_loss).to eq(1_100)

      collection << msft_lot1
      expect(collection.total_gain_loss).to eq(1_090)
    end
  end

  describe '#each' do
    it 'should itereate over the holdings' do
      collection = HoldingCollection.new [kss_lot1, kss_lot2, msft_lot1]
      symbols = collection.map { |h| h.commodity.symbol }
      expect(symbols).to eq(%w(KSS MSFT))
    end
  end
end
