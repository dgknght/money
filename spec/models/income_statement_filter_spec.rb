require 'spec_helper'

describe IncomeStatementFilter do  
  it 'is creatable from valid attributes' do
    filter = IncomeStatementFilter.new(from: '2013-01-01', to: '2013-01-31')
    expect(filter).to_not be_nil
    expect(filter).to be_valid
    expect(filter.from).to eq(Date.civil(2013, 1, 1))
    expect(filter.to).to eq(Date.civil(2013, 1, 31))
  end
   
  describe '#from' do
    it 'defaults to the start of the previous month' do
      Timecop.freeze(Chronic.parse('2015-02-27')) do
        filter = IncomeStatementFilter.new
        expect(filter.from).to eq(Date.parse('2015-01-01'))
      end
    end
  end
  
  describe '#to' do
  
    it 'cannot be before #from' do
      filter = IncomeStatementFilter.new(from: '2013-02-01', to: '2013-01-01')
      expect(filter).to_not be_valid
    end
  
    it 'defaults to the end of the previous month' do
      Timecop.freeze(Chronic.parse('2015-02-27')) do
        filter = IncomeStatementFilter.new
        expect(filter.to).to eq(Date.parse('2015-01-31'))
      end
    end
  end
end
