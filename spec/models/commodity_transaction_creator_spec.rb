require 'spec_helper'

describe CommodityTransactionCreator do
  let (:account) { FactoryGirl.create(:account) }
  let (:attributes) do
    {
      transaction_date: '2014-04-15',
      symbol: 'KSS',
      action: 'buy',
      shares: 100,
      value: 1_234.00
    }
  end

  it 'should be creatble with an account and valid attributes' do
    creator = CommodityTransactionCreator.new(account, attributes)
    expect(creator).to be_valid
    expect(creator.transaction_date).to eq(Date.parse('2014-04-15'))
    expect(creator.symbol).to eq('KSS')
    expect(creator.shares).to eq(100)
    expect(creator.value).to eq(1_234)
  end

  describe '#transaction_date' do
    it 'should default to the current date' do
      Timecop.freeze(Time.local(2014, 1, 1, 0, 0, 0)) do
        creator = CommodityTransactionCreator.new(account, attributes.except(:transaction_date))
        expect(creator).to be_valid
        expect(creator.transaction_date).to eq(Date.parse('2014-01-01'))
      end
    end
  end

  describe '#symbol' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(account, attributes.except(:symbol))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:symbol)
    end
  end

  describe '#action' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(account, attributes.except(:action))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:action)
    end

    it 'should accept "buy"' do
      creator = CommodityTransactionCreator.new(account, attributes.merge(:action => 'buy'))
      expect(creator).to be_valid
    end

    it 'should accept "sell"' do
      creator = CommodityTransactionCreator.new(account, attributes.merge(:action => 'sell'))
      expect(creator).to be_valid
    end

    it 'should not accept anything else' do
      creator = CommodityTransactionCreator.new(account, attributes.merge(action: 'notvalid'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:action)
    end
  end

  describe '#shares' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(account, attributes.except(:shares))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:shares)
    end

    it 'should be a number' do
      creator = CommodityTransactionCreator.new(account, attributes.merge(shares: 'notanumber'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:shares)
    end
  end

  describe '#price' do
    it 'should be calculated based on the value and shares' do
      creator = CommodityTransactionCreator.new(account, attributes)
      expect(creator.price).to eq(12.34)
    end
  end

  describe '#value' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(account, attributes.except(:value))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:value)
    end

    it 'should be a number' do
      creator = CommodityTransactionCreator.new(account, attributes.merge(value: 'notanumber'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:value)
    end
  end

  describe '#create' do
    context 'with a "buy" action' do
      it 'should create a new transaction'
      it 'should debit the account dedicated to tracking purchases of this commodity'
      it 'should credit the account from which frunds for taken to make the purchase'
    end

    context 'with a "sell" action' do
      it 'should create a new transaction'
      it 'should credit the account dedicated to tracking purchases of this commodity'
      it 'should debit the account to which products of the sale were directed'
    end
  end
end
