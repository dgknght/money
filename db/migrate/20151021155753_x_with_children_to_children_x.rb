class XWithChildrenToChildrenX < ActiveRecord::Migration
  def up
    change_table(:accounts) do |t|
      t.remove :cost_with_children, :gains_with_children, :value_with_children
      t.decimal :children_cost, default: 0, null: false
      t.decimal :children_gains, default: 0, null: false
      t.decimal :children_value, default: 0, null: false
    end
  end

  def down
    change_table(:accounts) do |t|
      t.remove :children_cost, :children_gains, :children_value
      t.decimal :cost_with_children, default: 0, null: false
      t.decimal :gains_with_children, default: 0, null: false
      t.decimal :value_with_children, default: 0, null: false
    end
  end
end
