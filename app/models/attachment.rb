# == Schema Information
#
# Table name: attachments
#
#  id                    :integer          not null, primary key
#  transaction_id        :integer          not null
#  name                  :text             not null
#  content_type          :text             not null
#  size                  :integer          not null
#  created_at            :datetime
#  updated_at            :datetime
#  attachment_content_id :integer          not null
#

class Attachment < ActiveRecord::Base
  belongs_to :transaction
  validates_presence_of :name, :transaction_id, :content_type
  before_validation :ensure_entity
  before_create :ensure_content

  def raw_file=(input)
    @content = AttachmentContent.new(raw_file: input)
    self.name ||= input.original_filename
    self.content_type = input.content_type.chomp
    @content.content_type = self.content_type
    self.size = @content.data.size
  end

  private
    def ensure_content
      return false unless @content && @content.save
      self.attachment_content_id = @content.id
      true
    end

    def ensure_entity
      return unless @content && self.transaction
      @content.entity_id = self.transaction.entity_id
    end
end
