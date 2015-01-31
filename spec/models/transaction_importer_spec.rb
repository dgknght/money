require 'spec_helper'

describe TransactionImporter do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:transaction_data) { Rails.root.join('spec', 'fixtures', 'files', 'transactions.csv') }
  let (:attributes) do
    {
      entity: entity,
      data: transaction_data
    }
  end
  let!(:checking) { FactoryGirl.create(:account, name: "Checking", entity: entity) }
  let!(:salary) { FactoryGirl.create(:account, name: "Salary", entity: entity, account_type: Account.income_type) }
  let!(:groceries) { FactoryGirl.create(:account, name: "Groceries", entity: entity, account_type: Account.expense_type) }

  it 'should be creatable from valid attributes' do
    importer = TransactionImporter.new(attributes)
    expect(importer).to be_valid
  end

  describe '#entity' do
    it 'should be required' do
      importer = TransactionImporter.new(attributes.except(:entity))
      expect(importer).not_to be_valid
      expect(importer).to have(1).error_on(:entity)
    end
  end

  describe '#data' do
    it 'should be required' do
      importer = TransactionImporter.new(attributes.except(:data))
      expect(importer).not_to be_valid
      expect(importer).to have(1).error_on(:data)
    end
  end

  describe '#import' do
    it 'should return true on success' do
      importer = TransactionImporter.new(attributes)
      expect(importer.import).to be_true
    end

    it 'should return false if unable to import the transactions' do
      importer = TransactionImporter.new(attributes.except(:data))
      expect(importer.import).to be_false
    end

    it 'should import the transactions' do
      expect do
        TransactionImporter.new(attributes).import
      end.to change(Transaction, :count).by(2)
    end
  end
end
