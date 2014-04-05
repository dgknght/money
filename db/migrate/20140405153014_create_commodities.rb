class CreateCommodities < ActiveRecord::Migration
  def change
    create_table :commodities do |t|
      t.integer :entity_id, nil: false
      t.string :name, nil: false
      t.string :symbol, nil: false, limit: 5
      t.string :market, nil: false, limit: 10

      t.timestamps
    end

    add_index :commodities, [:entity_id, :symbol], unique: true
  end
end
