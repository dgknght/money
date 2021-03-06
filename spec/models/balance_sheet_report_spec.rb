require 'spec_helper'

describe BalanceSheetReport do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:cash) { FactoryGirl.create(:asset_account, entity: entity, name: 'Cash') }
  let (:checking) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Checking') }
  let (:home) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Home') }
  let (:savings) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Savings') }
  let (:car) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Car', parent_id: savings.id) }
  let (:reserve) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Reserve', parent_id: savings.id) }
  let (:ira) { FactoryGirl.create(:commodities_account, entity_id: entity.id, name: 'IRA') }

  let (:credit_card) { FactoryGirl.create(:liability_account, entity_id: entity.id, name: 'Credit Card', balance: 2000) }
  let (:home_loan) { FactoryGirl.create(:liability_account, entity_id: entity.id, name: 'Home Loan', balance: 175000) }

  let (:opening_balances) { FactoryGirl.create(:equity_account, entity_id: entity.id, name: 'Opening Balances', balance: 10000) }

  let!(:kss) { FactoryGirl.create(:commodity, entity: entity, name: 'Knight Software Services', symbol: 'KSS') }

  let!(:checking_opening) do
    TransactionManager.create(entity, transaction_date: '2012-12-31',
                              description: 'opening balances',
                              items_attributes: [
                                {action: TransactionItem.credit, account_id: opening_balances.id, amount: 2000},
                                {action: TransactionItem.debit, account_id: checking.id, amount: 2000}
                              ]
                             )
  end
  let!(:home_opening) do
    TransactionManager.create(entity, transaction_date: '2012-12-31',
                              description: 'opening balances',
                              items_attributes: [
                                {action: TransactionItem.credit, account_id: opening_balances.id, amount: 200000},
                                {action: TransactionItem.debit, account_id: home.id, amount: 200000}
                              ]
                             )
  end
  let!(:car_opening) do
    TransactionManager.create(entity, transaction_date: '2012-12-31',
                              description: 'opening balances',
                              items_attributes: [
                                {action: TransactionItem.credit, account_id: opening_balances.id, amount: 10000},
                                {action: TransactionItem.debit, account_id: car.id, amount: 10000}
                              ]
                             )
  end
  let!(:reserve_opening) do
    TransactionManager.create(entity, transaction_date: '2012-12-31',
                              description: 'opening balances',
                              items_attributes: [
                                {action: TransactionItem.credit, account_id: opening_balances.id, amount: 30000},
                                {action: TransactionItem.debit, account_id: reserve.id, amount: 30000}
                              ]
                             )
  end
  let!(:credit_card_opening) do
    TransactionManager.create(entity, transaction_date: '2012-12-31',
                              description: 'opening balances',
                              items_attributes: [
                                {action: TransactionItem.credit, account_id: credit_card.id, amount: 2000},
                                {action: TransactionItem.debit, account_id: opening_balances.id, amount: 2000}
                              ]
                             )
  end
  let!(:home_loan_opening) do
    TransactionManager.create(entity, transaction_date: '2012-12-31',
                              description: 'opening balances',
                              items_attributes: [
                                {action: TransactionItem.credit, account_id: home_loan.id, amount: 175000},
                                {action: TransactionItem.debit, account_id: opening_balances.id, amount: 175000}
                              ]
                             )
  end
  let!(:ira_opening) do
    TransactionManager.create(entity, transaction_date: '2012-12-31',
                                      description: 'opening balances',
                                      items_attributes: [
                                        {action: TransactionItem.debit, account_id: ira.id, amount: 10_000},
                                        {action: TransactionItem.credit, account_id: opening_balances.id, amount: 10_000}
                                      ]
                                    )
  end

  let!(:purchase_kss) do
    CommodityTransactionCreator.new(entity: entity,
                                    transaction_date: '2013-01-02',
                                    account: ira,
                                    action: CommodityTransactionCreator.buy,
                                    symbol: kss.symbol,
                                    shares: 100,
                                    value: 1_000).create!
  end

  let!(:kss_price_update) do
    kss.prices.create!(trade_date: '2013-02-01',
                       price: 11)
  end
  let!(:kss_price_update_2) do
    kss.prices.create!(trade_date: '2013-03-01',
                       price: 9)
  end

  let(:filter) { BalanceSheetFilter.new(as_of: Date.civil(2012, 12, 31), hide_zero_balances: true) }
  let(:filter_with_zeros) { BalanceSheetFilter.new(as_of: Date.civil(2012, 12, 31), hide_zero_balances: false) }

  it 'is creatable with a valid filter' do
    report = BalanceSheetReport.new(entity, filter)
    expect(report).to_not be_nil
  end

  it 'renders a list of report rows' do
    report = BalanceSheetReport.new(entity, filter_with_zeros)
    expect(report.content).to eq([
      { account: 'Assets',                balance: '252,000.00', depth: 0 },
      { account: 'Cash',                  balance:       '0.00', depth: 1 },
      { account: 'Checking',              balance:   '2,000.00', depth: 1 },
      { account: 'Home',                  balance: '200,000.00', depth: 1 },
      { account: 'IRA',                   balance:  '10,000.00', depth: 1 },
      { account: 'Savings',               balance:  '40,000.00', depth: 1 },
      { account: 'Car',                   balance:  '10,000.00', depth: 2 },
      { account: 'Reserve',               balance:  '30,000.00', depth: 2 },
      { account: 'Liabilities',           balance: '177,000.00', depth: 0 },
      { account: 'Credit Card',           balance:   '2,000.00', depth: 1 },
      { account: 'Home Loan',             balance: '175,000.00', depth: 1 },
      { account: 'Equity',                balance:  '75,000.00', depth: 0 },
      { account: 'Opening Balances',      balance:  '75,000.00', depth: 1 },
      { account: 'Retained Earnings',     balance:       '0.00', depth: 1 },
      { account: 'Unrealized Gains',      balance:       '0.00', depth: 1 },
      { account: 'Liabilities + Equity',  balance: '252,000.00', depth: 0 }
    ])
  end

  it 'accounts for commodity purchases' do
    report = BalanceSheetReport.new(entity, BalanceSheetFilter.new(as_of: '2013-01-31', hide_zero_balances: false))
    # no change in value because the commodity is worth exactly what we paid
    # for it on the day we bought it
    expect(report.content).to eq([
      { account: 'Assets',                balance: '252,000.00', depth: 0 },
      { account: 'Cash',                  balance:       '0.00', depth: 1 },
      { account: 'Checking',              balance:   '2,000.00', depth: 1 },
      { account: 'Home',                  balance: '200,000.00', depth: 1 },
      { account: 'IRA',                   balance:  '10,000.00', depth: 1 },
      { account: 'Savings',               balance:  '40,000.00', depth: 1 },
      { account: 'Car',                   balance:  '10,000.00', depth: 2 },
      { account: 'Reserve',               balance:  '30,000.00', depth: 2 },
      { account: 'Liabilities',           balance: '177,000.00', depth: 0 },
      { account: 'Credit Card',           balance:   '2,000.00', depth: 1 },
      { account: 'Home Loan',             balance: '175,000.00', depth: 1 },
      { account: 'Equity',                balance:  '75,000.00', depth: 0 },
      { account: 'Opening Balances',      balance:  '75,000.00', depth: 1 },
      { account: 'Retained Earnings',     balance:       '0.00', depth: 1 },
      { account: 'Unrealized Gains',      balance:       '0.00', depth: 1 },
      { account: 'Liabilities + Equity',  balance: '252,000.00', depth: 0 }
    ])
  end

  it 'accounts for commodity price increases' do
    report = BalanceSheetReport.new(entity, BalanceSheetFilter.new(as_of: '2013-02-28', hide_zero_balances: false))
    # increased price causes the value of the asset account to rise and an increase in unrealized gains
    expect(report.content).to eq([
      { account: 'Assets',                balance: '252,100.00', depth: 0 },
      { account: 'Cash',                  balance:       '0.00', depth: 1 },
      { account: 'Checking',              balance:   '2,000.00', depth: 1 },
      { account: 'Home',                  balance: '200,000.00', depth: 1 },
      { account: 'IRA',                   balance:  '10,100.00', depth: 1 },
      { account: 'Savings',               balance:  '40,000.00', depth: 1 },
      { account: 'Car',                   balance:  '10,000.00', depth: 2 },
      { account: 'Reserve',               balance:  '30,000.00', depth: 2 },
      { account: 'Liabilities',           balance: '177,000.00', depth: 0 },
      { account: 'Credit Card',           balance:   '2,000.00', depth: 1 },
      { account: 'Home Loan',             balance: '175,000.00', depth: 1 },
      { account: 'Equity',                balance:  '75,100.00', depth: 0 },
      { account: 'Opening Balances',      balance:  '75,000.00', depth: 1 },
      { account: 'Retained Earnings',     balance:       '0.00', depth: 1 },
      { account: 'Unrealized Gains',      balance:     '100.00', depth: 1 },
      { account: 'Liabilities + Equity',  balance: '252,100.00', depth: 0 }
    ])
  end

  it 'accounts for commodity price decreases' do
    report = BalanceSheetReport.new(entity, BalanceSheetFilter.new(as_of: '2013-03-31', hide_zero_balances: false))
    # increased price causes the value of the asset account to rise and an increase in unrealized gains
    expect(report.content).to eq([
      { account: 'Assets',                balance: '251,900.00', depth: 0 },
      { account: 'Cash',                  balance:       '0.00', depth: 1 },
      { account: 'Checking',              balance:   '2,000.00', depth: 1 },
      { account: 'Home',                  balance: '200,000.00', depth: 1 },
      { account: 'IRA',                   balance:   '9,900.00', depth: 1 },
      { account: 'Savings',               balance:  '40,000.00', depth: 1 },
      { account: 'Car',                   balance:  '10,000.00', depth: 2 },
      { account: 'Reserve',               balance:  '30,000.00', depth: 2 },
      { account: 'Liabilities',           balance: '177,000.00', depth: 0 },
      { account: 'Credit Card',           balance:   '2,000.00', depth: 1 },
      { account: 'Home Loan',             balance: '175,000.00', depth: 1 },
      { account: 'Equity',                balance:  '74,900.00', depth: 0 },
      { account: 'Opening Balances',      balance:  '75,000.00', depth: 1 },
      { account: 'Retained Earnings',     balance:       '0.00', depth: 1 },
      { account: 'Unrealized Gains',      balance:    '-100.00', depth: 1 },
      { account: 'Liabilities + Equity',  balance: '251,900.00', depth: 0 }
    ])
  end

  context 'with #hide_zero_balances=true' do
    it 'omits records with a balance of zero' do
      report = BalanceSheetReport.new(entity, filter)
      expect(report.content).to eq([
        { account: 'Assets',                balance: '252,000.00', depth: 0 },
        { account: 'Checking',              balance:   '2,000.00', depth: 1 },
        { account: 'Home',                  balance: '200,000.00', depth: 1 },
        { account: 'IRA',                   balance:  '10,000.00', depth: 1 },
        { account: 'Savings',               balance:  '40,000.00', depth: 1 },
        { account: 'Car',                   balance:  '10,000.00', depth: 2 },
        { account: 'Reserve',               balance:  '30,000.00', depth: 2 },
        { account: 'Liabilities',           balance: '177,000.00', depth: 0 },
        { account: 'Credit Card',           balance:   '2,000.00', depth: 1 },
        { account: 'Home Loan',             balance: '175,000.00', depth: 1 },
        { account: 'Equity',                balance:  '75,000.00', depth: 0 },
        { account: 'Opening Balances',      balance:  '75,000.00', depth: 1 },
        { account: 'Retained Earnings',     balance:       '0.00', depth: 1 },
        { account: 'Unrealized Gains',      balance:       '0.00', depth: 1 },
        { account: 'Liabilities + Equity',  balance: '252,000.00', depth: 0 }
      ])
    end
  end
end
