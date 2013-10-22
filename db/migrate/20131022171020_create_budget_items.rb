class CreateBudgetItems < ActiveRecord::Migration
  def change
    create_table :budget_items do |t|
      t.integer :budget_id, null: false
      t.integer :account_id, null: false

      t.timestamps
    end
    add_index :budget_items, [:budget_id, :account_id], unique: true
  end
end
