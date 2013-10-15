class CreateBudgets < ActiveRecord::Migration
  def change
    create_table :budgets do |t|
      t.integer :entity_id, null: false
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end
    
    add_index :budgets, :entity_id
    add_index :budgets, :start_date
    add_index :budgets, :name, unique: true
  end
end
