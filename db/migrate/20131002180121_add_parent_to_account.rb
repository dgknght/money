class AddParentToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :parent_id, :integer
    add_index :accounts, :parent_id
  end
end
