class AddNextAndPreviousToTransactionItem < ActiveRecord::Migration
  def up
    change_table(:transaction_items) do |t|
      t.integer :next_transaction_item_id
      t.integer :previous_transaction_item_id
    end
    change_table(:accounts) do |t|
      t.integer :head_transaction_item_id
      t.integer :first_transaction_item_id
    end
    Account.find_each{|a| a.rebuild_transaction_item_links}
  end

  def down
    change_table(:transaction_items) do |t|
      t.remove :next_transaction_item_id
      t.remove :previous_transaction_item_id
    end
    change_table(:accounts) do |t|
      t.remove :head_transaction_item_id
      t.remove :first_transaction_item_id
    end
  end
end
