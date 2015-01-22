class AddMemoAndConfirmationToTransactionItems < ActiveRecord::Migration
  def change
    change_table(:transaction_items) do |t|
      t.string :memo, limit: 100
      t.string :confirmation, limit: 50
    end
  end
end
