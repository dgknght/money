require 'spec_helper'

describe GnucashImporter do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:gnucash_data) { Rails.root.join('spec', 'fixtures', 'files', 'sample.gnucash') }
  let (:attributes) do
    {
      data: Struct.new(:tempfile).new(gnucash_data),
      entity: entity
    }
  end

  it 'should be creatable from valid attributes' do
    importer = GnucashImporter.new(attributes)
    expect(importer).to be_valid
  end

  describe '#entity' do
    it 'should be required' do
      importer = GnucashImporter.new(attributes.except(:entity))
      expect(importer).not_to be_valid
    end
  end

  describe '#data' do
    it 'should be required' do
      importer = GnucashImporter.new(attributes.except(:data))
      expect(importer).not_to be_valid
    end
  end

  describe '#import!' do
    it 'should create the correct number of accounts' do
      importer = GnucashImporter.new(attributes)
      expect do
        importer.import!
      end.to change(Account, :count).by(22)
    end

    it 'should create the correct accounts' do
      GnucashImporter.new(attributes).import!
      expect(Account.all.map(&:name).sort).to eq(["401k", "AAPL", "Checking", "Current Assets", "Federal Income", "Fixed Assets",
                                                 "Groceries", "House", "Imbalance-USD", "Interest", "Investments",
                                                 "Loans", "Medicare", "Opening Balances", "Rent", "Salary", "Social Security",
                                                 "Taxes", "VTSAX", "Vehicle", "Vehicle Loan", "Vehicle Loan Interest"])
    end

    it 'should assign commodity accounts the commodity content type' do
      GnucashImporter.new(attributes).import!
      aapl = Account.find_by_name("AAPL")
      expect(aapl.content_type).to eq(Account.commodity_content)
    end

    it 'should assign commodity container accounts (i.e., investment accounts) the commodities content type' do
      GnucashImporter.new(attributes).import!
      four_oh_one_k = Account.find_by_name("401k")
      expect(four_oh_one_k.content_type).to eq(Account.commodities_content)
    end

    it 'should create the specified commodities' do
      expect do
        GnucashImporter.new(attributes).import!
      end.to change(Commodity, :count).by(2)
    end

    it 'should import commodity prices' do
      expect do
        GnucashImporter.new(attributes).import!
      end.to change(Price, :count).by(8)
    end

    it 'should reflect the correct reconciliation state for each transaction item'

    it 'should create the specified transactions' do
      importer = GnucashImporter.new(attributes)
      expect do
        importer.import!
      end.to change(Transaction, :count).by(22)
    end

    it 'should result in a balance sheet report with correct balances' do
      GnucashImporter.new(attributes).import!
      report = BalanceSheetReport.new(entity, BalanceSheetFilter.new(as_of: '2015-02-28'))
      expected = [{account: "Assets"              , balance: "249,721.00", depth: 0},
                  {account: "Current Assets"      , balance:   "2,688.00", depth: 1},
                  {account: "Checking"            , balance:   "2,688.00", depth: 2},
                  {account: "Fixed Assets"        , balance: "225,000.00", depth: 1},
                  {account: "House"               , balance: "200,000.00", depth: 2},
                  {account: "Vehicle"             , balance:  "25,000.00", depth: 2},
                  {account: "Imbalance-USD"       , balance:       "0.00", depth: 1},
                  {account: "Investments"         , balance:  "22,033.00", depth: 1},
                  {account: "401k"                , balance:  "22,033.00", depth: 2},
                  {account: "Liabilities"         , balance:  "24,400.00", depth: 0},
                  {account: "Loans"               , balance:  "24,400.00", depth: 1},
                  {account: "Vehicle Loan"        , balance:  "24,400.00", depth: 2},
                  {account: "Equity"              , balance: "225,321.00", depth: 0},
                  {account: "Opening Balances"    , balance: "220,000.00", depth: 1},
                  {account: "Retained Earnings"   , balance:   "3,288.00", depth: 1},
                  {account: "Unrealized Gains"    , balance:   "2,033.00", depth: 1},
                  {account: "Liabilities + Equity", balance: "249,721.00", depth: 0}]
      expect(report.content).to eq(expected)
    end

    it 'should result in an income statement with correct balances' do
      GnucashImporter.new(attributes).import!
      report = IncomeStatementReport.new(entity, IncomeStatementFilter.new(from: Chronic.parse("2015-01-01"), to: Chronic.parse("2015-12-31")))
      expected = [{account: "Income"                , balance: "8,000.00", depth: 0},
                  {account: "Salary"                , balance: "8,000.00", depth: 1},
                  {account: "Expense"               , balance: "4,712.00", depth: 0},
                  {account: "Groceries"             , balance:   "800.00", depth: 1},
                  {account: "Interest"              , balance:   "100.00", depth: 1},
                  {account: "Vehicle Loan Interest" , balance:   "100.00", depth: 2},
                  {account: "Rent"                  , balance: "1,600.00", depth: 1},
                  {account: "Taxes"                 , balance: "2,212.00", depth: 1},
                  {account: "Federal Income"        , balance: "1,600.00", depth: 2},
                  {account: "Medicare"              , balance:   "116.00", depth: 2},
                  {account: "Social Security"       , balance:   "496.00", depth: 2},
                  {account: "Net"                   , balance: "3,288.00", depth: 0}]
      expect(report.content).to eq(expected)
    end
  end
end
