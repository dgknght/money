class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.integer :user_id, null: false
      t.string :name, null: false, limit: 100

      t.timestamps
    end
  end
end
