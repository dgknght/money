class BalanceWithChildrenToChildrenBalance < ActiveRecord::Migration
  def change
    change_table(:accounts) do |t|
      t.decimal :children_balance, null: false, default: 0
    end
    remove_column :accounts, :balance_with_children, :decimal, null: false, default: 0
  end
end
