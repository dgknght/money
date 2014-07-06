class AddUniqueConstraintToPricesTradeDate < ActiveRecord::Migration
  def up
    remove_index :prices, [:commodity_id, :trade_date]
    add_index :prices, [:commodity_id, :trade_date], unique: true
  end

  def down
    remove_index :prices, [:commodity_id, :trade_date]
    add_index :prices, [:commodity_id, :trade_date]
  end
end
