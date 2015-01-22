Given(/^the transaction "([^"]+)" on (#{DATE_VALUE}) has an attachment named "([^"]+)"$/) do |transaction_description, transaction_date, attachment_name|
  transaction = Transaction.where(transaction_date: transaction_date.to_date, description: transaction_description).first
  expect(transaction).not_to be_nil
  path = Rails.root.join('features', 'resources', 'attachment.png') 
  raw_file = Rack::Test::UploadedFile.new(path, 'image/png')
  attachment = transaction.attachments.new(raw_file: raw_file)
  attachment.name = attachment_name
  attachment.save!
end
