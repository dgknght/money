require 'spec_helper'

describe Attachment do

  let (:transaction) { FactoryGirl.create(:transaction) }
  let (:attributes) do
    {
      transaction_id: transaction.id,
      name: 'Photo.jpg',
      content_type: 'image/jpeg'
    }
  end

  it 'should be creatable from valid attributes' do
    attachment = Attachment.new(attributes)
    expect(attachment).not_to be_nil
    expect(attachment).to be_valid
    expect(attachment.name).to eq('Photo.jpg')
    expect(attachment.content_type).to eq('image/jpeg')
    expect(attachment.transaction_id).to eq(transaction.id)
  end

  describe 'name' do
    it 'should be required' do
      attachment = Attachment.new(attributes.without(:name))
      expect(attachment).not_to be_valid
      expect(attachment).to have(1).error_on(:name)
    end
  end

  describe 'content_type' do
    it 'should be required' do
      attachment = Attachment.new(attributes.without(:content_type))
      expect(attachment).not_to be_valid
      expect(attachment).to have(1).error_on(:content_type)
    end
  end

  describe 'transaction_id' do
    it 'should be required' do
      attachment = Attachment.new(attributes.without(:transaction_id))
      expect(attachment).not_to be_valid
      expect(attachment).to have(1).error_on(:transaction_id)
    end
  end

  describe 'transaction' do
    it 'should refer to the transaction to which the attachment belongs' do
      attachment = Attachment.new(attributes);
      expect(attachment.transaction).not_to be_nil
    end
  end
end
