require 'spec_helper'

describe Commodity do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:attributes) do
    {
      name: 'Knight Software Services',
      symbol: 'KSS',
      market: Commodity.nyse
    }
  end
  let (:all_attributes) do
    attributes.merge(entity_id: entity.id)
  end

  let (:other_entity) { FactoryGirl.create(:entity) }

  it 'should be creatable from valid attributes' do
    commodity = Commodity.new(all_attributes)
    expect(commodity).to be_valid
  end

  describe '#name' do
    it 'should be required' do
      commodity = entity.commodities.new(attributes.except(:name))
      expect(commodity).not_to be_valid
    end

    it 'should be unique within an entity' do
      c1 = entity.commodities.create!(attributes)
      c2 = entity.commodities.new(attributes.merge(symbol: 'XYZ'))
      expect(c2).to have(1).error_on(:name)
    end

    it 'should allow duplicates across markets' do
      c1 = entity.commodities.create!(attributes)
      c2 = entity.commodities.new(attributes.merge(market: Commodity.amex))
      expect(c2).to have(:no).errors_on(:name)
    end

    it 'should allow duplicates across entities' do
      c1 = entity.commodities.create!(attributes)
      c2 = other_entity.commodities.new(attributes.merge(symbol: 'XYZ'))
      expect(c2).to have(:no).errors_on(:name)
    end
  end

  describe '#symbol' do
    it 'should be required' do
      commodity = entity.commodities.new(attributes.except(:symbol))
      expect(commodity).not_to be_valid
    end

    it 'cannot contain spaces' do
      commodity = entity.commodities.new(attributes.merge(symbol: 'A B'))
      expect(commodity).not_to be_valid
    end

    it 'should be unique within an entity' do
      c1 = entity.commodities.create!(attributes)
      c2 = entity.commodities.new(attributes.merge(name: 'John Doe Software Services'))
      expect(c2).to have(1).error_on(:symbol)
    end

    it 'should allow duplicates across markets' do
      c1 = entity.commodities.create!(attributes)
      c2 = entity.commodities.new(attributes.merge(market: Commodity.amex))
      expect(c2).to have(:no).errors_on(:symbol)
    end

    it 'should allow duplicates across entities' do
      c1 = entity.commodities.create!(attributes)
      c2 = other_entity.commodities.new(attributes.merge(name: 'John Doe Software Services'))
      expect(c2).to have(:no).errors_on(:symbol)
    end

    it 'should not be longer than 10 characters' do
      commodity = entity.commodities.new(attributes.merge(symbol: "OTTFFSSENTE"))
      expect(commodity).to have(1).error_on(:symbol)
    end
  end

  describe '#market' do
    it 'should be required' do
      commodity = entity.commodities.new(attributes.except(:market))
      expect(commodity).not_to be_valid
    end

    it 'should only accept valid values' do
      commodity = entity.commodities.new(attributes.merge(market: Commodity.nasdaq))
      expect(commodity).to be_valid

      commodity.market = 'fake'
      expect(commodity).not_to be_valid
    end
  end

  describe '#prices' do
    it 'should list the prices for the commodity' do
      commodity = entity.commodities.new(attributes)
      expect(commodity).to respond_to(:prices)
    end
  end

  describe '#latest_price' do
    let (:commodity) { FactoryGirl.create(:commodity) }
    let!(:p1) do
      FactoryGirl.create(:price, commodity: commodity,
                                 trade_date: '2014-01-03',
                                 price: 11.11)
    end
    let!(:p2) do
      FactoryGirl.create(:price, commodity: commodity,
                                 trade_date: '2014-01-02',
                                 price: 10.00)
    end
    it 'should return the most recent price for the commodity' do
      expect(commodity.latest_price).to eq(p1)
    end
  end

  describe '#lots' do
    let (:commodity) { FactoryGirl.create(:commodity) }
    let!(:lot) { FactoryGirl.create(:lot, commodity: commodity) }

    it 'should return the lots for the commodity' do
      expect(commodity).to have(1).lot
    end
  end

  describe '#destroy' do
    let!(:commodity) { FactoryGirl.create(:commodity, entity: entity) }
    let!(:ira) { FactoryGirl.create(:asset_account, entity: entity, content_type: Account.commodities_content) }
    let!(:transaction) { CommodityTransactionCreator.new(symbol: commodity.symbol,
                                                         account: ira,
                                                         shares: 100,
                                                         action: 'buy',
                                                         value: 1_000).create! }

    it 'should remove all constituent lots from the system' do
      expect{commodity.destroy!}.to change(Lot, :count).by(-1)
    end

    it 'should remove all constituent prices from the system' do
      expect{commodity.destroy!}.to change(Price, :count).by(-1)
    end
  end
end
