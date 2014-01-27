class CreateAttachmentContents < ActiveRecord::Migration
  def change
    create_table :attachment_contents do |t|
      t.belongs_to :attachment
      t.binary :data, null: false

      t.timestamps
    end

    add_index :attachment_contents, :attachment_id, unique: true
  end
end
