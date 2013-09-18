class AddUserIdToTransaction < ActiveRecord::Migration
  def up
    add_column :transactions, :user_id, :integer
    change_column :transactions, :user_id, :integer, null: false
  end
  
  def down
    remove_column :transactions, :user_id
  end
end
