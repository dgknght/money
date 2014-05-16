require 'spec_helper'

describe CommodityTransactionCreator do
  let!(:commodity) { FactoryGirl.create(:commodity, symbol: 'KSS', name: 'Knight Software Services') }
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
        transaction = nil
        expect do
          creator = CommodityTransactionCreator.new(attributes)
          transaction = creator.create
        end.to change(Transaction, :count).by(1)

        expect(transaction).not_to be_nil
        expect(transaction.total_debits.to_i).to eq(1_234)
      end

      it 'should create an account to track money used to purchase this commodity, if the account does not exist' do
        CommodityTransactionCreator.new(attributes).create
        expect(Account.find_by_name('KSS')).not_to be_nil
      end

      it 'should debit the account dedicated to tracking purchases of this commodity' do
        CommodityTransactionCreator.new(attributes).create
        new_account = Account.find_by_name('KSS')
        expect(new_account.balance).to eq(1_234)
      end

      it 'should credit the account from which frunds for taken to make the purchase' do
        expect do
          CommodityTransactionCreator.new(attributes).create
          account.reload
        end.to change(account, :balance).by(-1_234)
      end

      it 'should create a new lot transaction' do
        expect do
          CommodityTransactionCreator.new(attributes).create
        end.to change(LotTransaction, :count).by(1)
      end

      it 'should create a new lot' do
        transaction = nil
        expect do
          CommodityTransactionCreator.new(attributes).create
        end.to change(Lot, :count).by(1)
      end
    end

    context 'with a "sell" action' do
      it 'should create a new transaction'
      it 'should credit the account dedicated to tracking purchases of this commodity'
      it 'should debit the account to which products of the sale were directed'
      it 'should create a capital gains transaction if the sale amount was greater than the cost of the sold commodities'
      it 'should create a capital loss transaction if the sale amount was less than the cost of the cold commodities'

      context 'using FIFO' do
        it 'should subtract shares from the first purchased, non-empty lot'
      end

      context 'using FILO' do
        it 'should subtract shares from the last purchased, non-empty lot'
      end
    end
  end
end
