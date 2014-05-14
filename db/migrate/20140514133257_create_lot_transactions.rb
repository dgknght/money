class CreateLotTransactions < ActiveRecord::Migration
  def change
    create_table :lot_transactions do |t|
      t.integer :lot_id, null: false
      t.integer :transaction_id, null: false
      t.decimal :shares_traded, null: false, precision: 8, scale: 4
      t.decimal :price, null: false, precision: 8, scale: 4

      t.timestamps
    end
    add_index :lot_transactions, :lot_id
  end
end
