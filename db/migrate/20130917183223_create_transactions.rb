class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date :transaction_date, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
