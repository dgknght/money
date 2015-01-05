class CreateBudgetMonitors < ActiveRecord::Migration
  def change
    create_table :budget_monitors do |t|
      t.integer :entity_id, null: false
      t.integer :account_id, null: false

      t.timestamps
    end

    add_index :budget_monitors, :account_id, unique: true
  end
end
