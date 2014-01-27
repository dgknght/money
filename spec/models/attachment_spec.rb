require 'spec_helper'

describe Attachment do

  let (:transaction) { FactoryGirl.create(:transaction) }
  let (:file) { File.new(Rails.root.join('spec', 'resources', 'attachment.png')) }
  let (:attributes) do
    {
      transaction_id: transaction.id,
      raw_file: ActionDispatch::Http::UploadedFile.new(tempfile: file, filename: 'attachment.png', type: 'image/png')
    }
  end

  it 'should be creatable from valid attributes' do
    attachment = Attachment.new(attributes)
    expect(attachment).not_to be_nil
    expect(attachment).to be_valid
    expect(attachment.name).to eq('attachment.png')
    expect(attachment.content_type).to eq('image/png')
    expect(attachment.transaction_id).to eq(transaction.id)
  end

  describe 'raw_file' do
    it 'should be required' do
      attachment = Attachment.new(attributes.without(:raw_file))
      expect(attachment).not_to be_valid
      expect(attachment).to have(1).error_on(:name)
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
