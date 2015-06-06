# == Schema Information
#
# Table name: attachment_contents
#
#  id           :integer          not null, primary key
#  data         :binary           not null
#  created_at   :datetime
#  updated_at   :datetime
#  entity_id    :integer
#  content_type :text             not null
#

class AttachmentContent < ActiveRecord::Base
  belongs_to :entity, inverse_of: :attachment_contents
  validates_presence_of :data, :entity_id

  def raw_file=(input)
    input.rewind if input.eof?
    self.data = input.read
  end
end
