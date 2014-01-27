class Attachment < ActiveRecord::Base
  belongs_to :transaction
  has_one :content, class_name: AttachmentContent, autosave: true, dependent: :destroy
  validates_presence_of :name, :transaction_id, :content_type

  def raw_file=(input)
    if content
      new_content = self.content
      new_content.raw_file = input
    else
      new_content = build_content(raw_file: input)
    end

    self.name = input.original_filename
    self.content_type = input.content_type.chomp
    self.size = new_content.data.size
  end
end
