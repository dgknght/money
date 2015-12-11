require 'spec_helper'

describe BalanceSheetFilter do
  it 'is creatable from valid attributes' do
    filter = BalanceSheetFilter.new(as_of: '2013-01-01')
    expect(filter.as_of).to eq(Date.civil(2013, 1, 1))
  end

  it 'accepts standard US date format' do
    filter = BalanceSheetFilter.new(as_of: '1/1/2013')
    expect(filter.as_of).to eq(Date.civil(2013, 1, 1))
  end
  
  describe 'as_of' do
    it 'defaults to today' do
      filter = BalanceSheetFilter.new
      expect(filter.as_of).to eq(Date.today)
    end
  end

  describe 'hide_zero_balances' do
    it 'defaults to true' do
      filter = BalanceSheetFilter.new
      expect(filter.hide_zero_balances).to be true
    end
  end
end
