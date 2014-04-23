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
      expect(c2).not_to be_valid
    end

    it 'should allow duplicates across entities' do
      c1 = entity.commodities.create!(attributes)
      c2 = other_entity.commodities.new(attributes.merge(symbol: 'XYZ'))
      expect(c2).to be_valid
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
      expect(c2).not_to be_valid
    end

    it 'should allow duplicates across entities' do
      c1 = entity.commodities.create!(attributes)
      c2 = other_entity.commodities.new(attributes.merge(name: 'John Doe Software Services'))
      expect(c2).to be_valid
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
end
