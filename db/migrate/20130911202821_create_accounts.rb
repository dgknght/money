class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name, :null => false
      t.string :account_type, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end
  end
end
