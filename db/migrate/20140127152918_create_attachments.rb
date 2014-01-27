class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :transaction_id, null: false
      t.text :name, null: false
      t.text :content_type, null: false

      t.timestamps
    end

    add_index :attachments, :transaction_id
  end
end
