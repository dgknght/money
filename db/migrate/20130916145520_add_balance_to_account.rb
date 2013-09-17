class AddBalanceToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :balance, :decimal, :null => false, :default => 0
  end
end
