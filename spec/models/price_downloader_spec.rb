require 'spec_helper'

describe PriceDownloader do
  let (:entity) { FactoryGirl.create(:entity) }

  it 'should be creatable from an entity' do
    downloader = PriceDownloader.new(entity)
    expect(downloader).not_to be_nil
  end

  describe '#download' do
    it 'should query the configured service client to get prices for existing entities'
  end
end
