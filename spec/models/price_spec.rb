require 'spec_helper'

describe Price do
  let (:commodity) { FactoryGirl.create(:commodity) }
  let (:attributes) do
    {
      trade_date: '2014-02-27',
      price: '123.4567'
    }
  end
  let (:all_attributes) { attributes.merge(commodity_id: commodity.id) }

  it 'should be creatable from valid attributes' do
    price = Price.new(all_attributes)
    expect(price).to be_valid
  end

  describe '#commodity_id' do
    it 'should be required' do
      price = Price.new(all_attributes.except(:commodity_id))
      expect(price).not_to be_valid
      expect(price).to have(1).error_on(:commodity_id)
    end
  end

  describe '#commodity' do
    it 'should reference the commodity to which the price belongs' do
      price = Price.new(all_attributes)
      expect(price.commodity).to eq(commodity)
    end
  end

  describe '#trade_date' do
    it 'should be required' do
      price = commodity.prices.new(attributes.except(:trade_date))
      expect(price).not_to be_valid
      expect(price).to have(1).error_on(:trade_date)
    end
  end

  describe '#price' do
    it 'should be required' do
      price = commodity.prices.new(attributes.except(:price))

      expect(price).not_to be_valid
      expect(price).to have(2).errors_on(:price)
    end

    it 'should be greater than zero' do
      price = commodity.prices.new(attributes.merge(price: '-100.00'))
      expect(price).not_to be_valid
      expect(price).to have(1).errors_on(:price)
    end
  end
end
