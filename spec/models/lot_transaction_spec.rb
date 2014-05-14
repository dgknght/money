require 'spec_helper'

describe LotTransaction do
  let (:account) { FactoryGirl.create(:account) }
  let (:transaction) { FactoryGirl.create(:transaction, debit_account: account, amount: 2_500) }
  let (:lot) { FactoryGirl.create(:lot, account: account) }
  let (:attributes) do
    {
      lot_id: lot.id,
      transaction_id: transaction.id,
      shares_traded: 100,
      price: 25.00
    }
  end

  it 'should be creatable from valid attributes' do
    transaction = LotTransaction.new attributes
    expect(transaction).to be_valid
  end

  describe '#lot_id' do
    it 'should be required' do
      transaction = LotTransaction.new attributes.except(:lot_id)
      expect(transaction).not_to be_valid
      expect(transaction).to have(1).error_on(:lot_id)
    end
  end

  describe '#transaction_id' do
    it 'should be required' do
      transaction = LotTransaction.new attributes.except(:transaction_id)
      expect(transaction).not_to be_valid
      expect(transaction).to have(1).error_on(:transaction_id)
    end
  end

  describe '#shares_traded' do
    it 'should be required' do
      transaction = LotTransaction.new attributes.except(:shares_traded)
      expect(transaction).not_to be_valid
      expect(transaction).to have(1).error_on(:shares_traded)
    end
  end

  describe '#price' do
    it 'should be required' do
      transaction = LotTransaction.new attributes.except(:price)
      expect(transaction).not_to be_valid
      expect(transaction).to have(1).error_on(:price)
    end
  end

  describe '#lot' do
    it 'should reference the owning lot' do
      transaction = LotTransaction.new attributes
      expect(transaction.lot).not_to be_nil
    end
  end

  describe '#transaction' do
    it 'should reference the associated transaction' do
      transaction = LotTransaction.new attributes
      expect(transaction.transaction).not_to be_nil
    end
  end
end
