class AttachmentContent < ActiveRecord::Base
  belongs_to :entity
  validates_presence_of :data, :entity_id

  def raw_file=(input)
    input.rewind if input.eof?
    self.data = input.read
  end
end
