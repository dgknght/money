class AddReconciledToTransactionItem < ActiveRecord::Migration
  def change
    add_column :transaction_items, :reconciled, :boolean, null: false, default: false
  end
end
