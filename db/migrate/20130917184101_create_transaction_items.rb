class CreateTransactionItems < ActiveRecord::Migration
  def change
    create_table :transaction_items do |t|
      t.integer :transaction_id, null: false
      t.integer :account_id, null: false
      t.string :action, null: false
      t.decimal :amount, null: false

      t.timestamps
    end
  end
end
