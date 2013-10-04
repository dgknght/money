require 'spec_helper'

describe BalanceSheetFilter do
  let(:attributes) do
    {
      as_of: Date.civil(2013, 1, 1)
    }
  end
  
  it 'should be creatable from valid attributes' do
    filter = BalanceSheetFilter.new(attributes)
    filter.as_of.should == Date.civil(2013, 1, 1)
  end
  
  describe 'as_of' do
    it 'should default to today' do
      filter = BalanceSheetFilter.new
      filter.as_of.should == Date.today
    end
  end
end