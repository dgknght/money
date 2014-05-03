require 'spec_helper'

describe Holdings do
  let (:ira) { FactoryGirl.create(:commodity_account) }
  let (:kss) { FactoryGirl.create(:commodity, symbol: 'KSS', name: 'Knight Software Services') }

  it 'should be creatable from valid attributes' do
    holdings = Holdings.new(account: ira)
    expect(holdings).not_to be_nil
  end

  it 'should contain a record for each commodity held in the account' do
    holdings = Holdings.new(account: ira)
    expect(holdings).to be_none

    CommodityTransactionCreator.new(account: ira,
                                    symbol: 'KSS',
                                    action: 'buy',
                                    shares: 100,
                                    value: 1_000).create!

    expect(holdings).to eq([{
      commodity: kss,
      shares: 100,
      value: 1_000
    }])
  end

  it 'should omit commodities with a zero balance'
end
