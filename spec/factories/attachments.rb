# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attachment do
    association :owning_transaction, factory: :transaction
    raw_file { ActionDispatch::Http::UploadedFile.new(tempfile: File.new(Rails.root.join('spec', 'resources', 'attachment.png')), type: 'image/png', filename: 'attachment.png') }
  end
end
