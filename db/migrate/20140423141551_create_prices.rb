class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :commodity_id, null: false
      t.date :trade_date, null: false
      t.decimal :price, null: false, precision: 8, scale: 4

      t.timestamps
    end

    add_index :prices, [:commodity_id, :trade_date]
  end
end
