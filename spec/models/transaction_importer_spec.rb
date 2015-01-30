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
    it 'should return true on success'
    it 'should return false on failure'
    it 'should import the transactions'
  end
end
