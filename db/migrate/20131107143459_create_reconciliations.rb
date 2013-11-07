class CreateReconciliations < ActiveRecord::Migration
  def change
    create_table :reconciliations do |t|
      t.integer :account_id, null: false
      t.date :reconciliation_date, null: false
      t.decimal :closing_balance, null: false

      t.timestamps
    end
    
    add_index :reconciliations, [:account_id, :reconciliation_date]
  end
end
