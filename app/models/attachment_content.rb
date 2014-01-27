class AttachmentContent < ActiveRecord::Base
  belongs_to :attachment
  validates_presence_of :data

  def raw_file=(input)
    input.rewind if input.eof?
    self.data = input.read
  end
end
