class RemoveHeadTransactionItem < ActiveRecord::Migration
  def up
    change_table :accounts do |t|
      t.remove :head_transaction_item_id, :first_transaction_item_id
    end
  end

  def down
    change_table :accounts do |t|
      t.integer :head_transaction_item_id
      t.integer :first_transaction_item_id
    end
  end
end
