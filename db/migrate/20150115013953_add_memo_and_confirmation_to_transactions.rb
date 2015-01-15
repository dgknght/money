class AddMemoAndConfirmationToTransactions < ActiveRecord::Migration
  def change
    change_table(:transactions) do |t|
      t.string :memo, limit: 100
      t.string :confirmation, limit: 50
    end
  end
end
