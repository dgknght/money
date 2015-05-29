class AddBalanceToTransactionItems < ActiveRecord::Migration
  def change
    change_table(:transaction_items) do |t|
      t.decimal :balance, null: false, default: 0
    end
  end
end
