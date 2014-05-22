require 'spec_helper'

describe Holding do
  let (:kss) { FactoryGirl.create(:commodity, symbol: 'KSS') }
  let (:lot1) do
    FactoryGirl.create(:lot, commodity: kss,
                             price: 10.00,
                             shares_owned: 100,
                             purchase_date: '2014-01-01')
  end
  let (:lot2) do
    FactoryGirl.create(:lot, commodity: kss,
                             price: 12.00,
                             shares_owned: 50,
                             purchase_date: '2014-02-01')
  end

  it 'should be creatable with a lot' do
    holding = Holding.new(lot1)
    expect(holding).not_to be_nil
  end

  it 'should be creatable with an array of lots' do
    holding = Holding.new([lot1, lot2])
    expect(holding).not_to be_nil
  end

  describe '#total_shares' do
    it 'should be the sum of the shares of the lots added to the holding' do
      holding = Holding.new(lot1)
      expect(holding.total_shares).to eq(100)

      holding << lot2
      expect(holding.total_shares).to eq(150)
    end
  end

  describe '#average_price' do
    it 'should be the weighted average of the prices of the shares held across the lots' do
      holding = Holding.new(lot1)
      expect(holding.average_price).to eq(10.00)

      holding << lot2
      expect(holding.average_price.round(4)).to eq(10.6667)
    end
  end

  describe '#current_value' do
    let!(:price) do
      FactoryGirl.create(:price, commodity: kss,
                                 trade_date: '2014-05-01',
                                 price: 15.00)
    end
    it 'should be the sum of the current values of the lots' do
      holding = Holding.new(lot1)
      expect(holding.current_value).to eq(1_500.00)

      holding << lot2
      expect(holding.current_value.round(4)).to eq(2_250.00)
    end
  end

  describe '#<<' do
    let (:other_lot) { FactoryGirl.create(:lot, account: lot1.account) }

    it 'should add a lot to the holding' do
      holding = Holding.new(lot1)
      expect do
        holding << lot2
      end.to change(holding.lots, :count).by(1)
    end

    it 'should not accept a lot with a different commodity' do
      holding = Holding.new(lot1)
      expect do
        holding << other_lot
      end.to raise_error('All lots in the holding must belong to the same commodity')
    end
  end

  describe '#+' do
    let (:lot3) do
      FactoryGirl.create(:lot, commodity: kss,
                              price: 13.00,
                              shares_owned: 100,
                              purchase_date: '2014-03-01')
    end
    it 'should add an array of lots to the holding' do
      holding = Holding.new(lot1)
      expect do
        holding + [lot2, lot3]
      end.to change(holding.lots, :count).by(2)
    end
  end
end
