require 'spec_helper'

describe CommodityTransactionCreatorTest do
  let (:account) { FactoryGirl.create(:account) }
  let (:attributes) do
    {
      transaction_date: '2014-04-15',
      symbol: 'KSS',
      action: :buy,
      shares: 100,
      price: 12.34,
      value: 1_234.00
    }
  end

  it 'should be creatble with an account and valid attributes' do
    creator = CommodityTransactionCreator.new(account, attributes)
    expect(creator).to be_valid
  end
end
