require 'spec_helper'

describe BalanceSheetFilter do
  it 'should be creatable from valid attributes' do
    filter = BalanceSheetFilter.new(as_of: '2013-01-01')
    filter.as_of.should == Date.civil(2013, 1, 1)
  end

  it 'should accept standard US date format' do
    filter = BalanceSheetFilter.new(as_of: '1/1/2013')
    filter.as_of.should == Date.civil(2013, 1, 1)
  end
  
  describe 'as_of' do
    it 'should default to today' do
      filter = BalanceSheetFilter.new
      filter.as_of.should == Date.today
    end
  end
end
