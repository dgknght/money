class CreateLots < ActiveRecord::Migration
  def change
    create_table :lots do |t|
      t.integer :account_id, null: false
      t.integer :commodity_id, null: false
      t.decimal :price, null: false, precision: 8, scale: 4
      t.decimal :shares_owned, null: false, precision: 8, scale: 4
      t.date :purchase_date, null: false

      t.timestamps
    end
    add_index :lots, :account_id
  end
end
