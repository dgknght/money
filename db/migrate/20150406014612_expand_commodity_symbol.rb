class ExpandCommoditySymbol < ActiveRecord::Migration
  def up
    change_column :commodities, :symbol, :string, limit: 10
  end

  def down
    change_column :commodities, :symbol, :string, limit: 5
  end
end
