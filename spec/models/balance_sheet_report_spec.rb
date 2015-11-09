require 'spec_helper'

describe BalanceSheetReport do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Checking') }
  let (:home) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Home') }
  let (:savings) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Savings') }
  let (:car) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Car', parent_id: savings.id) }
  let (:reserve) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Reserve', parent_id: savings.id) }
  
  let (:credit_card) { FactoryGirl.create(:liability_account, entity_id: entity.id, name: 'Credit Card', balance: 2000) }
  let (:home_loan) { FactoryGirl.create(:liability_account, entity_id: entity.id, name: 'Home Loan', balance: 175000) }
  
  let (:opening_balances) { FactoryGirl.create(:equity_account, entity_id: entity.id, name: 'Opening Balances', balance: 10000) }
  
  let!(:checking_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: opening_balances.id, amount: 2000}, 
                                  {action: TransactionItem.debit, account_id: checking.id, amount: 2000}
                                ]
                                )
  end
  let!(:home_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: opening_balances.id, amount: 200000}, 
                                  {action: TransactionItem.debit, account_id: home.id, amount: 200000}
                                ]
                                )
  end
  let!(:car_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: opening_balances.id, amount: 10000}, 
                                  {action: TransactionItem.debit, account_id: car.id, amount: 10000}
                                ]
                                )
  end
  let!(:reserve_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: opening_balances.id, amount: 30000}, 
                                  {action: TransactionItem.debit, account_id: reserve.id, amount: 30000}
                                ]
                                )
  end
  let!(:credit_card_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 2000}, 
                                  {action: TransactionItem.debit, account_id: opening_balances.id, amount: 2000}
                                ]
                                )
  end
  let!(:home_loan_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: home_loan.id, amount: 175000}, 
                                  {action: TransactionItem.debit, account_id: opening_balances.id, amount: 175000}
                                ]
                                )
  end
  
  let(:filter) { BalanceSheetFilter.new(as_of: Date.civil(2012, 12, 31), hide_zero_balances: true) }
    
  it 'is creatable with a valid filter' do
    report = BalanceSheetReport.new(entity, filter)
    expect(report).to_not be_nil
  end
  
  it 'renders a list of report rows' do
    report = BalanceSheetReport.new(entity, filter)
    expect(report.content).to eq([
      { account: 'Assets',                balance: '242,000.00', depth: 0 },
      { account: 'Checking',              balance:   '2,000.00', depth: 1 },
      { account: 'Home',                  balance: '200,000.00', depth: 1 },
      { account: 'Savings',               balance:  '40,000.00', depth: 1 },
      { account: 'Car',                   balance:  '10,000.00', depth: 2 },
      { account: 'Reserve',               balance:  '30,000.00', depth: 2 },
      { account: 'Liabilities',           balance: '177,000.00', depth: 0 },
      { account: 'Credit Card',           balance:   '2,000.00', depth: 1 },
      { account: 'Home Loan',             balance: '175,000.00', depth: 1 },
      { account: 'Equity',                balance:  '65,000.00', depth: 0 },
      { account: 'Opening Balances',      balance:  '65,000.00', depth: 1 },
      { account: 'Retained Earnings',     balance:       '0.00', depth: 1 },
      { account: 'Unrealized Gains',      balance:       '0.00', depth: 1 },
      { account: 'Liabilities + Equity',  balance: '242,000.00', depth: 0 }
    ])
  end

  context 'with #hide_zero_balances=true' do
    let!(:cash) { FactoryGirl.create(:asset_account, entity: entity, name: 'Cash') }

    it 'omits records with a balance of zero' do
      report = BalanceSheetReport.new(entity, filter)
      expect(report.content).to eq([
        { account: 'Assets',                balance: '242,000.00', depth: 0 },
        { account: 'Checking',              balance:   '2,000.00', depth: 1 },
        { account: 'Home',                  balance: '200,000.00', depth: 1 },
        { account: 'Savings',               balance:  '40,000.00', depth: 1 },
        { account: 'Car',                   balance:  '10,000.00', depth: 2 },
        { account: 'Reserve',               balance:  '30,000.00', depth: 2 },
        { account: 'Liabilities',           balance: '177,000.00', depth: 0 },
        { account: 'Credit Card',           balance:   '2,000.00', depth: 1 },
        { account: 'Home Loan',             balance: '175,000.00', depth: 1 },
        { account: 'Equity',                balance:  '65,000.00', depth: 0 },
        { account: 'Opening Balances',      balance:  '65,000.00', depth: 1 },
        { account: 'Retained Earnings',     balance:       '0.00', depth: 1 },
        { account: 'Unrealized Gains',      balance:       '0.00', depth: 1 },
        { account: 'Liabilities + Equity',  balance: '242,000.00', depth: 0 }
      ])
    end
  end
end
