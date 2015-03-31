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
    it 'should create the specified accounts' do
      importer = GnucashImporter.new(attributes)
      expect do
        importer.import!
      end.to change(Account, :count).by(18)
    end

    it 'should create the specified commodities'
    it 'should create the specified transactions'
    it 'should result in a balance sheet report with correct balances'
    # TODO Should we test income statement also?
  end
end
