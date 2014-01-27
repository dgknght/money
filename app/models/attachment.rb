class Attachment < ActiveRecord::Base
  belongs_to :transaction
  validates_presence_of :name, :transaction_id, :content_type
end
