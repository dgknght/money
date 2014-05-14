require 'spec_helper'

describe Lot do
  let (:account) { FactoryGirl.create(:account) }
  let (:commodity) { FactoryGirl.create(:commodity) }
  let (:attributes) do
    {
      account_id: account.id,
      commodity_id: commodity.id,
      price: 12.345,
      shares_owned: 43.21,
      purchase_date: '2014-5-13'
    }
  end

  it 'should be creatable from valid attributes' do
    lot = Lot.new attributes
    expect(lot).to be_valid
  end

  describe '#acount_id' do
    it 'should be required' do
      lot = Lot.new attributes.except(:account_id)
      expect(lot).not_to be_valid
      expect(lot).to have(1).error_on(:account_id)
    end
  end

  describe '#price' do
    it 'should be required' do
      lot = Lot.new attributes.except(:price)
      expect(lot).not_to be_valid
      expect(lot).to have(2).errors_on(:price)
    end

    it 'should be greater than zero' do
      lot = Lot.new attributes.merge(price: -1)
      expect(lot).not_to be_valid
      expect(lot).to have(1).error_on(:price)
    end
  end

  describe '#commodity_id' do
    it 'should be required' do
      lot = Lot.new attributes.except(:commodity_id)
      expect(lot).not_to be_valid
    end
  end

  describe '#shares_owned' do
    it 'should be required' do
      lot = Lot.new attributes.except(:shares_owned)
      expect(lot).not_to be_valid
    end
  end

  describe '#purchase_date' do
    it 'should be required' do
      lot = Lot.new attributes.except(:purchase_date)
      expect(lot).not_to be_valid
    end
  end

  describe '#current_value' do
    let!(:price2) { FactoryGirl.create(:price, commodity: commodity, trade_date: '2014-05-13', price: 20) }
    let!(:price1) { FactoryGirl.create(:price, commodity: commodity, trade_date: '2014-05-01', price: 10) }
    it 'should return the value of the lot based on the specified date' do
      lot = Lot.create!(attributes)
      expect(lot.current_value).to eq(864.20)
    end

    it 'should return the value of the lot based on the current date if no date is specified' do
      log = Lot.create!(attributes)
      expect(log.current_value('2014-05-02')).to eq(432.10)
    end
  end
end
