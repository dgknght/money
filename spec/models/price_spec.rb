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

  it 'is creatable from valid attributes' do
    price = Price.new(all_attributes)
    expect(price).to be_valid
  end

  describe '#commodity_id' do
    it 'is required' do
      price = Price.new(all_attributes.except(:commodity_id))
      expect(price).not_to be_valid
      expect(price).to have(1).error_on(:commodity_id)
    end
  end

  describe '#commodity' do
    it 'references the commodity to which the price belongs' do
      price = Price.new(all_attributes)
      expect(price.commodity).to eq(commodity)
    end
  end

  describe '#trade_date' do
    it 'is required' do
      price = commodity.prices.new(attributes.except(:trade_date))
      expect(price).not_to be_valid
      expect(price).to have(1).error_on(:trade_date)
    end

    it 'is unique for a given commodity' do
      commodity.prices.create!(attributes)
      price = commodity.prices.create(attributes.merge(price: 125))
      expect(price).not_to be_valid
      expect(price).to have(1).error_on(:trade_date)
    end
  end

  describe '#price' do
    it 'is required' do
      price = commodity.prices.new(attributes.except(:price))

      expect(price).not_to be_valid
      expect(price).to have(2).errors_on(:price)
    end

    it 'is greater than zero' do
      price = commodity.prices.new(attributes.merge(price: '-100.00'))
      expect(price).not_to be_valid
      expect(price).to have(1).errors_on(:price)
    end

    it 'is less than 10,000' do
      price = commodity.prices.new(attributes.merge(price: '10_000'))
      expect(price).to have(1).error_on(:price)
    end
  end

  describe '::put_price' do
    context 'when no price record exists for the specified date' do
      it 'creates a price record' do
        expect do
          Price.put_price(commodity, '2014-02-27', 100)
        end.to change(Price, :count).by(1)
      end
    end

    context 'when a price record exists for the specified date' do
      let!(:price) { commodity.prices.create!(trade_date: '2014-02-27', price: 100) }

      it 'does not create a price record if one exists for the specified date' do
        expect do
          Price.put_price(commodity, '2014-02-27', 100)
        end.not_to change(Price, :count)
      end

      it 'updates a price record if one exists for the specified date' do
        expect do
          Price.put_price(commodity, '2014-02-27', 100)
          price.reload
        end.not_to change(price, :price)
      end
    end
  end
end
