require 'spec_helper'

describe PriceDownloader do
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:kss) { FactoryGirl.create(:commodity, symbol: 'KSS', name: 'Knight Software Services', entity: entity) }

  it 'should be creatable from an entity' do
    downloader = PriceDownloader.new(entity)
    expect(downloader).not_to be_nil
  end

  describe '#download' do
    before(:each) do
      PriceDownloader::MemoryDownloadAgent.put('KSS', '2014-01-01', 12.34)
    end

    it 'should query the configured service client to get prices for existing entities' do
      expect do
        PriceDownloader.new(entity).download
      end.to change(Price, :count).by(1)
    end
  end
end
