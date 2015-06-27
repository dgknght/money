class AddSuspendBalanceRecalculationsToEntities < ActiveRecord::Migration
  def change
    change_table(:entities) do |t|
      t.boolean :suspend_balance_recalculations, null: false, default: false
    end
  end
end
