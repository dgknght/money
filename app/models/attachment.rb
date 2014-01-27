class Attachment < ActiveRecord::Base
  before_validation :process_raw_file
  belongs_to :transaction
  validates_presence_of :name, :transaction_id, :content_type

  attr_accessor :raw_file

  private
    def process_raw_file
      return unless self.raw_file

      input = self.raw_file
      self.name = input.original_filename
      self.content_type = input.content_type.chomp
      self.size = 0
    end
end
