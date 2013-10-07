require 'spec_helper'

describe IncomeStatementFilter do  
  it 'should be creatable from valid attributes' do
    filter = IncomeStatementFilter.new(from: '2013-01-01', to: '2013-01-31')
    filter.should_not be_nil
    filter.should be_valid
    filter.from.should == Date.civil(2013, 1, 1)
    filter.to.should == Date.civil(2013, 1, 31)
  end
   
# TODO Add suspension library and test these specs 
#  describe 'start_date' do
#    it 'should default to the start of the previous month'
#  end
  
  describe 'end_date' do
  
    it 'cannot be before the start date' do
      filter = IncomeStatementFilter.new(from: '2013-02-01', to: '2013-01-01')
      filter.should_not be_valid
    end
  
# TODO Add suspension library and test these specs 
#    it 'should default to the end of the previous month'
  end
end