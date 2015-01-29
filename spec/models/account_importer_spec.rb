require 'spec_helper'

describe AccountImporter do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:account_data) { Rails.root.join('spec', 'fixtures', 'files', 'accounts.csv') }
  let (:attributes) do
    {
      data: account_data,
      entity: entity
    }
  end

  it 'should be creatable with valid attributes' do
    importer = AccountImporter.new(attributes)
    expect(importer).to be_valid
  end

  describe '#entity' do
    it 'should be required' do
      importer = AccountImporter.new(attributes.except(:entity))
      expect(importer).not_to be_valid
      expect(importer).to have(1).error_on(:entity)
    end
  end

  describe '#data' do
    it 'should be required' do
      importer = AccountImporter.new(attributes.except(:data))
      expect(importer).not_to be_valid
      expect(importer).to have(1).error_on(:data)
    end
  end

  describe '#import' do
    it 'should create an account for each account found in the file' do
      importer = AccountImporter.new(attributes)
      importer.import
      expect(Account.all.map(&:name)).to eq(["Cash",
                                             "Checking",
                                             "Savings",
                                             "Car",
                                             "Reserve",
                                             "Credit Card",
                                             "Salary",
                                             "Groceries",
                                             "Telephone",
                                             "Opening Balances"])
    end

    it 'should assign child accounts to their parent' do
      importer = AccountImporter.new(attributes)
      importer.import
      reserve = Account.find_by_name("Reserve")
      expect(reserve.parent.try(:name)).to eq("Savings")
    end
  end
end
