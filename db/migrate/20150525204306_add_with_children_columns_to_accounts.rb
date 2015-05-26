class AddWithChildrenColumnsToAccounts < ActiveRecord::Migration
  def change
    change_table :accounts do |t|
      t.decimal :cost                 , default: 0, null: false
      t.decimal :gains                , default: 0, null: false
      t.decimal :value                , default: 0, null: false
      t.decimal :balance_with_children, default: 0, null: false
      t.decimal :cost_with_children   , default: 0, null: false
      t.decimal :gains_with_children  , default: 0, null: false
      t.decimal :value_with_children  , default: 0, null: false
    end
  end
end
