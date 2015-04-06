class FixCommodityUniqueness < ActiveRecord::Migration
  def up
    remove_index :commodities, [:entity_id, :symbol]
    add_index :commodities, [:entity_id, :market, :symbol], unique: true
    add_index :commodities, [:entity_id, :market, :name], unique: true
  end

  def down
    remove_index :commodities, [:entity_id, :market, :symbol]
    remove_index :commodities, [:entity_id, :market, :name]
    add_index :commodities, [:entity_id, :symbol], unique: true
  end
end
