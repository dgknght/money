require 'spec_helper'

describe CommoditySplitter do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:kss) { FactoryGirl.create(:commodity, entity: entity, symbol: 'KSS') }
  let (:ira) { FactoryGirl.create(:asset_account, entity: entity, content_type: Account.commodities_content) }
  let (:ob) { FactoryGirl.create(:equity_account, entity: entity) }
  let!(:t1) do
    FactoryGirl.create(:transaction, description: 'Opening balance',
                                      transaction_date: Chronic.parse('2015-01-01'),
                                      amount: 10_000,
                                      debit_account: ira,
                                      credit_account: ob)
  end
  let!(:t2) do
    CommodityTransactionCreator.new(symbol: 'KSS',
                                    action: 'buy',
                                    shares: 100,
                                    value: 2_000,
                                    transaction_date: Chronic.parse('2015-01-02'),
                                    account: ira).create!
  end
  let (:attributes) do
    {
      numerator: 2,
      denominator: 1,
      commodity: kss
    }
  end

  it 'should be creatable from valid attributes' do
    splitter = CommoditySplitter.new(attributes)
    expect(splitter).to be_valid
  end

  describe '#commodity' do
    it 'is required' do
      splitter = CommoditySplitter.new(attributes.without(:commodity))
      expect(splitter).to have_at_least(1).error_on(:commodity)
    end
  end

  describe '#numerator' do
    it 'is required' do
      splitter = CommoditySplitter.new(attributes.except(:numerator))
      expect(splitter).to have_at_least(1).error_on(:numerator)
    end

    it 'must be a number' do
      splitter = CommoditySplitter.new(attributes.merge(numerator: 'notanumber'))
      expect(splitter).to have_at_least(1).error_on(:numerator)
    end
  end

  describe '#denominator' do
    it 'defaults to 1' do
      splitter = CommoditySplitter.new(attributes.except(:denominator))
      expect(splitter.denominator).to eq(1)
    end

    it 'must be a number' do
      splitter = CommoditySplitter.new(attributes.merge(denominator: 'notanumber'))
      expect(splitter).to have(1).error_on(:denominator)
    end
  end

  describe '#split' do
    it 'changes the number of shares owned for the commodity in all current lots' do
      lots = kss.lots.to_a
      expect do
        CommoditySplitter.new(attributes).split
        lots.each{|l| l.reload}
      end.to change(lots.first, :shares_owned).from(BigDecimal.new(100)).to(BigDecimal(200))
    end

    it 'changes the price records for all current lots' do
      prices = kss.prices.to_a
      expect do
        CommoditySplitter.new(attributes).split
        prices.each{|p| p.reload}
      end.to change(prices.first, :price).from(BigDecimal.new(20)).to(BigDecimal.new(10))
    end

    it 'does not change the current value for any current lots' do
      lots = kss.lots.to_a
      expect do
        CommoditySplitter.new(attributes).split
        lots.each{|l| l.reload}
      end.not_to change(lots.first, :current_value)
    end
  end
end
