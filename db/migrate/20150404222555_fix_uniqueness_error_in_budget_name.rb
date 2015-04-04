class FixUniquenessErrorInBudgetName < ActiveRecord::Migration
  def up
    remove_index :budgets, :name
    remove_index :budgets, :entity_id
    add_index :budgets, [:entity_id, :name], unique: true
  end

  def down
    remove_index :budgets, [:entity_id, :name]
    add_index :budgets, :entity_id
    add_index :budgets, :name, unique: true
  end
end
