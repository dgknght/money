require 'spec_helper'

describe AccountImporter do
  let (:account_data) { Rails.root.join('spec', 'fixtures', 'files', 'accounts.csv') }

  it 'should be creatable without attributes' do
    importer = AccountImporter.new
    expect(importer).to be_valid
  end

  it 'should be creatable with valid attributes' do
    importer = AccountImporter.new(data: account_data)
  end

  describe '#import' do
    it 'should create an account for each account found in the file' do
      importer = AccountImporter.new(data: account_data)
      importer.import
      expect(Account.all.map(&:name)).to eq(%w(Cash Checking Savings Car Reserve Credit_Card Salary Groceries Telephone Opening_Balances))
    end
  end
end
