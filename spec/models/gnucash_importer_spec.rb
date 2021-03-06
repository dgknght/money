require 'spec_helper'

describe GnucashImporter do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:gnucash_data) { Rails.root.join('spec', 'fixtures', 'files', 'sample.gnucash') }
  let (:attributes) do
    {
      data: gnucash_data,
      entity: entity
    }
  end

  it 'is creatable from valid attributes' do
    importer = GnucashImporter.new(attributes)
    expect(importer).to be_valid
  end

  describe '#entity' do
    it 'is required' do
      importer = GnucashImporter.new(attributes.except(:entity))
      expect(importer).not_to be_valid
    end
  end

  describe '#data' do
    it 'is required' do
      importer = GnucashImporter.new(attributes.except(:data))
      expect(importer).not_to be_valid
    end
  end

  describe '#import!' do
    it 'creates the correct number of accounts' do
      importer = GnucashImporter.new(attributes)
      expect do
        importer.import!
      end.to change(Account, :count).by(23)
    end

    it 'creates the correct accounts' do
      GnucashImporter.new(attributes).import!
      expect(Account.all.map(&:name).sort).to eq(["401k", "AAPL", "Checking", "Current Assets", "Federal Income", "Fixed Assets",
                                                 "Groceries", "House", "Imbalance-USD", "Interest", "Investment Expenses", "Investments",
                                                 "Loans", "Medicare", "Opening Balances", "Rent", "Salary", "Social Security",
                                                 "Taxes", "VTSAX", "Vehicle", "Vehicle Loan", "Vehicle Loan Interest"])
    end

    it 'assigns commodity accounts the commodity content type' do
      GnucashImporter.new(attributes).import!
      aapl = Account.find_by_name("AAPL")
      expect(aapl.content_type).to eq(Account.commodity_content)
    end

    it 'assigns commodity container accounts (i.e., investment accounts) the commodities content type' do
      GnucashImporter.new(attributes).import!
      four_oh_one_k = Account.find_by_name("401k")
      expect(four_oh_one_k.content_type).to eq(Account.commodities_content)
    end

    it 'creates the specified commodities' do
      expect do
        GnucashImporter.new(attributes).import!
      end.to change(Commodity, :count).by(2)
    end

    it 'imports commodity prices' do
      expect do
        GnucashImporter.new(attributes).import!
      end.to change(Price, :count).by(8)
    end

    it 'includes memos in commodity transactions' do
      GnucashImporter.new(attributes).import!
      account = Account.find_by(name: '401k')

      item = account.transaction_items.select{|i| /AAPL/ =~ i.owning_transaction.description}.first
      expect(item.memo).to eq('comment about the account')

      other_item = item.owning_transaction.items.reject{|i| i.id == item.id}.first
      expect(other_item.memo).to eq('comment about the shares')
    end

    it 'marks reconciled items as reconciled' do
      GnucashImporter.new(attributes).import!
      checking = Account.find_by(name: 'Checking')
      r = checking.transaction_items.
            joins(:owning_transaction).
            where('transactions.transaction_date' => Chronic.parse('2015-01-01 00:00:00 UTC')..Chronic.parse('2015-01-31 23:59:59 UTC')).
            map(&:reconciled)
      expect(Set.new(r)).to eq(Set.new([true]))
    end

    it 'leaves unreconciled items unreconciled' do
      GnucashImporter.new(attributes).import!
      checking = Account.find_by(name: 'Checking')
      r = checking.transaction_items.
            joins(:owning_transaction).
            where('transactions.transaction_date' => Chronic.parse('2015-02-01 00:00:00 UTC')..Chronic.parse('2015-02-28 23:59:59 UTC')).
            map(&:reconciled)
      expect(Set.new(r)).to eq(Set.new([false]))
    end

    it 'creates the specified transactions' do
      importer = GnucashImporter.new(attributes)
      expect do
        importer.import!
      end.to change(Transaction, :count).by(22)
    end

    it 'includes transaction item memos' do
      GnucashImporter.new(attributes).import!
      groceries = Account.find_by(name: 'Groceries')
      expect(groceries.transaction_items.first.memo).to eq('comment about the groceries')
    end

    it 'results in a balance sheet report with correct balances' do
      GnucashImporter.new(attributes).import!
      report = BalanceSheetReport.new(entity, BalanceSheetFilter.new(as_of: '2015-02-28', hide_zero_balances: false))
      expected = [{account: "Assets"              , balance: "249,711.00", depth: 0},
                  {account: "Current Assets"      , balance:   "2,688.00", depth: 1},
                  {account: "Checking"            , balance:   "2,688.00", depth: 2},
                  {account: "Fixed Assets"        , balance: "225,000.00", depth: 1},
                  {account: "House"               , balance: "200,000.00", depth: 2},
                  {account: "Vehicle"             , balance:  "25,000.00", depth: 2},
                  {account: "Imbalance-USD"       , balance:       "0.00", depth: 1},
                  {account: "Investments"         , balance:  "22,023.00", depth: 1},
                  {account: "401k"                , balance:  "22,023.00", depth: 2},
                  {account: "Liabilities"         , balance:  "24,400.00", depth: 0},
                  {account: "Loans"               , balance:  "24,400.00", depth: 1},
                  {account: "Vehicle Loan"        , balance:  "24,400.00", depth: 2},
                  {account: "Equity"              , balance: "225,311.00", depth: 0},
                  {account: "Opening Balances"    , balance: "220,000.00", depth: 1},
                  {account: "Retained Earnings"   , balance:   "3,278.00", depth: 1},
                  {account: "Unrealized Gains"    , balance:   "2,033.00", depth: 1},
                  {account: "Liabilities + Equity", balance: "249,711.00", depth: 0}]
      expect(report.content).to eq(expected)
    end

    it 'results in an income statement with correct balances' do
      GnucashImporter.new(attributes).import!
      report = IncomeStatementReport.new(entity, IncomeStatementFilter.new(from: Chronic.parse("2015-01-01"), to: Chronic.parse("2015-12-31")))
      expected = [{account: "Income"                , balance: "8,000.00", depth: 0},
                  {account: "Salary"                , balance: "8,000.00", depth: 1},
                  {account: "Expense"               , balance: "4,722.00", depth: 0},
                  {account: "Groceries"             , balance:   "800.00", depth: 1},
                  {account: "Interest"              , balance:   "100.00", depth: 1},
                  {account: "Vehicle Loan Interest" , balance:   "100.00", depth: 2},
                  {account: "Investment Expenses"   , balance:    "10.00", depth: 1},
                  {account: "Rent"                  , balance: "1,600.00", depth: 1},
                  {account: "Taxes"                 , balance: "2,212.00", depth: 1},
                  {account: "Federal Income"        , balance: "1,600.00", depth: 2},
                  {account: "Medicare"              , balance:   "116.00", depth: 2},
                  {account: "Social Security"       , balance:   "496.00", depth: 2},
                  {account: "Net"                   , balance: "3,278.00", depth: 0}]
      expect(report.content).to eq(expected)
    end
  end
end
