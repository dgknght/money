class InvertAttachmentContentRelationship < ActiveRecord::Migration
  def up
    change_table :attachments do |t|
      t.integer :attachment_content_id
    end

    change_table :attachment_contents do |t|
      t.integer :entity_id
      t.text :content_type
    end

    sql = "update attachments
           set attachment_content_id = (
            select id
            from attachment_contents
            where attachment_contents.attachment_id = attachments.id
           )"
    Attachment.connection.execute(sql);
    sql = "update attachment_contents
           set content_type = (
            select content_type
            from attachments
            where attachment_contents.attachment_id = attachments.id
           )"
    Attachment.connection.execute(sql);
    sql = "update attachment_contents
           set entity_id = (
            select entities.id
            from attachment_contents
              inner join attachments on attachments.id = attachment_contents.attachment_id
              inner join transactions on transactions.id = attachments.transaction_id
              inner join entities on entities.id = transactions.entity_id
            where attachment_contents.attachment_id = attachments.id
           )"
    Attachment.connection.execute(sql);

    change_table :attachment_contents do |t|
      t.remove :attachment_id
    end

    change_column_null :attachments, :attachment_content_id, false
    change_column_null :attachment_contents, :content_type, false
  end

  def down
    change_table :attachment_contents do |t|
      t.integer :attachment_id
      t.index :attachment_id, unique: true
      t.remove :entity_id, :content_type
    end

    sql = "update attachment_contents
           set attachment_id = (
            select id
            from attachments
            where attachments.attachment_content_id = attachment_contents.id
           )"
    Attachment.connection.execute(sql);

    change_table :attachments do |t|
      t.remove :attachment_content_id
    end
  end
end
