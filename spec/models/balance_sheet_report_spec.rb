require 'spec_helper'

describe BalanceSheetReport do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:checking) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Checking', balance: 2000) }
  let!(:home) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Home', balance: 200000) }
  let!(:savings) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Savings', balance: 0) }
  let!(:car) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Car', balance: 10000, parent_id: savings.id) }
  let!(:reserve) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Reserve', balance: 30000, parent_id: savings.id) }
  
  let!(:credit_card) { FactoryGirl.create(:liability_account, entity_id: entity.id, name: 'Credit Card', balance: 2000) }
  let!(:home_loan) { FactoryGirl.create(:liability_account, entity_id: entity.id, name: 'Home Loan', balance: 175000) }
  
  let!(:opening_balances) { FactoryGirl.create(:equity_account, entity_id: entity.id, name: 'Opening Balances', balance: 10000) }
  
  let(:filter) { BalanceSheetFilter.new(as_of: Date.civil(2012, 12, 31)) }
  
  it 'should be creatable with a valid filter' do
    report = BalanceSheetReport.new(entity, filter)
    report.should_not be_nil
  end
  
  it 'should render a list of report rows' do
    report = BalanceSheetReport.new(entity, filter)
    report.content.should == [
      { account: 'Assets',            balance: '242,000.00', depth: 0 },
      { account: 'Checking',          balance:   '2,000.00', depth: 1 },
      { account: 'Home',              balance: '200,000.00', depth: 1 },
      { account: 'Savings',           balance:  '40,000.00', depth: 1 },
      { account: 'Car',               balance:  '10,000.00', depth: 2 },
      { account: 'Reserve',           balance:  '30,000.00', depth: 2 },
      { account: 'Liabilities',       balance: '177,000.00', depth: 0 },
      { account: 'Credit Card',       balance:   '2,000.00', depth: 1 },
      { account: 'Home Loan',         balance: '175,000.00', depth: 1 },
      { account: 'Equity',            balance:  '65,000.00', depth: 0 },
      { account: 'Opening Balances',  balance:  '10,000.00', depth: 1 },
      { account: 'Retained Earnings', balance:  '55,000.00', depth: 1 }
    ]
  end
end