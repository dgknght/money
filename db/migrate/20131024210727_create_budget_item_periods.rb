class CreateBudgetItemPeriods < ActiveRecord::Migration
  def change
    create_table :budget_item_periods do |t|
      t.integer :budget_item_id, null: false
      t.date :start_date, null: false
      t.decimal :budget_amount, null: false

      t.timestamps
    end
    
    add_index :budget_item_periods, [:budget_item_id, :start_date]
  end
end
