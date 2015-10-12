class LinkedListToIndex < ActiveRecord::Migration
  def up
    change_table :transaction_items do |t|
      t.remove :next_transaction_item_id, :previous_transaction_item_id
      t.integer :index, default: 0, null: false
    end

    add_index :transaction_items, [:account_id, :index]
  end

  def down
    change_table :transaction_items do |t|
      t.integer :next_transaction_item_id
      t.integer :previous_transaction_item_id
      t.remove_index [:account_id, :index]
      t.remove :index
    end
  end
end
