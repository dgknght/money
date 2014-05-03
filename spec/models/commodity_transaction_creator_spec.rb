require 'spec_helper'

describe CommodityTransactionCreator do
  let (:account) { FactoryGirl.create(:account) }
  let (:attributes) do
    {
      account_id: account.id,
      transaction_date: '2014-04-15',
      symbol: 'KSS',
      action: 'buy',
      shares: 100,
      value: 1_234.00
    }
  end

  it 'should be creatable with an account and valid attributes' do
    creator = CommodityTransactionCreator.new(attributes)
    expect(creator).to be_valid
    expect(creator.transaction_date).to eq(Date.parse('2014-04-15'))
    expect(creator.symbol).to eq('KSS')
    expect(creator.shares).to eq(100)
    expect(creator.value).to eq(1_234)
  end

  describe '#account_id' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:account_id))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:account_id)
    end
  end

  describe '#transaction_date' do
    it 'should default to the current date' do
      Timecop.freeze(Time.local(2014, 1, 1, 0, 0, 0)) do
        creator = CommodityTransactionCreator.new(attributes.except(:transaction_date))
        expect(creator).to be_valid
        expect(creator.transaction_date).to eq(Date.parse('2014-01-01'))
      end
    end
  end

  describe '#symbol' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:symbol))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:symbol)
    end
  end

  describe '#action' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:action))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:action)
    end

    it 'should accept "buy"' do
      creator = CommodityTransactionCreator.new(attributes.merge(:action => 'buy'))
      expect(creator).to be_valid
    end

    it 'should accept "sell"' do
      creator = CommodityTransactionCreator.new(attributes.merge(:action => 'sell'))
      expect(creator).to be_valid
    end

    it 'should not accept anything else' do
      creator = CommodityTransactionCreator.new(attributes.merge(action: 'notvalid'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:action)
    end
  end

  describe '#shares' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:shares))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:shares)
    end

    it 'should be a number' do
      creator = CommodityTransactionCreator.new(attributes.merge(shares: 'notanumber'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:shares)
    end
  end

  describe '#price' do
    it 'should be calculated based on the value and shares' do
      creator = CommodityTransactionCreator.new(attributes)
      expect(creator.price).to eq(12.34)
    end
  end

  describe '#value' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:value))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:value)
    end

    it 'should be a number' do
      creator = CommodityTransactionCreator.new(attributes.merge(value: 'notanumber'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:value)
    end
  end

  describe '#create' do
    context 'with a "buy" action' do
      it 'should create a new transaction' do
        expect do
          creator = CommodityTransactionCreator.new(attributes)
          currency_trans, commodity_trans = creator.create
        end.to change(Transaction, :count).by(2) # 1 for the currency and 1 for the commodity

        expect(currency_trans).not_to be_nil
        expect(currency_trans.total_debits).to eq(1_234)

        expect(commodity_trans).not_to be_nil
        expect(commodity_trans.total_debits).to eq(100)
      end

      it 'should debit the account dedicated to tracking purchases of this commodity'
      it 'should credit the account from which frunds for taken to make the purchase'
      it 'should increase the number of shares held of this commodity'
    end

    context 'with a "sell" action' do
      it 'should create a new transaction'
      it 'should credit the account dedicated to tracking purchases of this commodity'
      it 'should debit the account to which products of the sale were directed'
    end
  end
end
