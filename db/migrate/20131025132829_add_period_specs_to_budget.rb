class AddPeriodSpecsToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :period, :string, limit: 20, null: false, default: 'month'
    add_column :budgets, :period_count, :integer, null: false, default: 12
    
    remove_column :budgets, :end_date, :date
  end
end
