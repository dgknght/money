class CreateReconciliationItems < ActiveRecord::Migration
  def change
    create_table :reconciliation_items do |t|
      t.integer :reconciliation_id, null: false
      t.integer :transaction_item_id, null: false

      t.timestamps
    end

    add_index :reconciliation_items, :reconciliation_id
    add_index :reconciliation_items, :transaction_item_id
  end
end
