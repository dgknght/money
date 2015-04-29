require 'spec_helper'

describe LotTransfer do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:kss) { FactoryGirl.create(:commodity, symbol: 'KSS') }
  let (:four01k) { FactoryGirl.create(:commodities_account, entity: entity) }
  let (:ira) { FactoryGirl.create(:commodities_account, entity: entity) }
  let (:opening) { FactoryGirl.create(:equity_account, entity: entity) }
  let!(:t1) { FactoryGirl.create(:transaction, amount: 2_000, debit_account: four01k, credit_account: opening) }
  let!(:t2) { CommodityTransactionCreator.new(account: four01k, shares: 100, value: 1_000, action: 'buy', symbol: 'KSS').create! }
  let (:lot) { kss.lots.first }
  let (:attributes) do
    {
      target_account: ira,
      lot: lot
    }
  end

  it 'should be creatable from valid attributes' do
    transfer = LotTransfer.new(attributes)
    expect(transfer).to be_valid
  end

  describe '#target_account' do
    it 'should be required' do
      transfer = LotTransfer.new(attributes.except(:target_account))
      expect(transfer).to have_at_least(1).error_on(:target_account)
    end
  end

  describe '#lot' do
    it 'should be required' do
      transfer = LotTransfer.new(attributes.except(:lot))
      expect(transfer).to have_at_least(1).error_on(:lot)
    end
  end

  describe '#transfer' do
    it 'should remove the lot from the source commodity account' do
      kss_account = four01k.children.find_by_name('KSS')
      expect do
        LotTransfer.new(attributes).transfer
      end.to change(kss_account.lots, :count).from(1).to(0)
    end

    it 'should create the target commodity account, if it does not exist' do
      LotTransfer.new(attributes).transfer
      expect(ira).to have(1).child
    end

    it 'should add the lot to the target commodity account' do
      LotTransfer.new(attributes).transfer
      expect(ira.children.find_by_name('KSS')).to have(1).lot
    end

    it 'should not change the shares in the lot' do
      expect do
        LotTransfer.new(attributes).transfer
        lot.reload
      end.not_to change(lot, :shares_owned)
    end

    it 'should not change the current value of the lot' do
      expect do
        LotTransfer.new(attributes).transfer
        lot.reload
      end.not_to change(lot, :current_value)
    end
  end
end
