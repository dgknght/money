require 'spec_helper'

describe CommodityExchanger do
  let (:entity) {FactoryGirl.create(:entity)}
  let (:ira) {FactoryGirl.create(:commodities_account, entity: entity, name: 'IRA')}
  let (:ob) {FactoryGirl.create(:equity_account, entity: entity, name: 'Opening balances')}
  let!(:kss) {FactoryGirl.create(:commodity, entity: entity, symbol: 'KSS')}
  let!(:ksx) {FactoryGirl.create(:commodity, entity: entity, symbol: 'KSX')}
  let!(:t1) {FactoryGirl.create(:transaction, entity: entity, amount: 1_000, debit_account: ira, credit_account: ob)}
  let!(:ct1) do
    CommodityTransactionCreator.new(account: ira,
                                    action: CommodityTransactionCreator.buy,
                                    symbol: 'KSS',
                                    shares: 100,
                                    value: 1_000).create!
  end
  let (:lot) {kss.lots.first}
  let (:attributes) do
    {
      lot_id: lot.id,
      commodity_id: ksx.id
    }
  end

  it 'should be creatable from valid attributes' do
    exchanger = CommodityExchanger.new(attributes)
    expect(exchanger).to be_valid
  end

  describe '#lot_id' do
    it 'is required' do
      exchanger = CommodityExchanger.new(attributes.except(:lot_id))
      expect(exchanger).to have_at_least(1).error_on(:lot_id)
    end
  end

  describe '#commodity_id' do
    it 'is required' do
      exchanger = CommodityExchanger.new(attributes.except(:commodity_id))
      expect(exchanger).to have_at_least(1).error_on(:commodity_id)
    end
  end

  describe '#exchange' do
    it 'removes shares of the original commodity' do
      CommodityExchanger.new(attributes).exchange
      expect(kss).to have(0).lots
    end

    it 'add shares of the specified commodity' do
      CommodityExchanger.new(attributes).exchange
      expect(ksx).to have(1).lot
    end

    it 'does not change the cost basis of the shares' do
      expect do
        CommodityExchanger.new(attributes).exchange
      end.not_to change(ira, :cost_with_children)
    end
  end
end
