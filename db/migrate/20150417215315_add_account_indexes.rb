class AddAccountIndexes < ActiveRecord::Migration
  def change
    add_index :accounts, [:entity_id, :parent_id, :name], unique: true
  end
end
