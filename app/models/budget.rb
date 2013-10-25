# == Schema Information
#
# Table name: budgets
#
#  id           :integer          not null, primary key
#  entity_id    :integer          not null
#  name         :string(255)      not null
#  start_date   :date             not null
#  created_at   :datetime
#  updated_at   :datetime
#  period       :string(20)       default("month"), not null
#  period_count :integer          default(12), not null
#

class Budget < ActiveRecord::Base
  PERIODS = %w(year month week)
  class << self
    PERIODS.each do |period|
      define_method period do
        period
      end
    end
  end
  
  belongs_to :entity
  has_many :items, class_name: 'BudgetItem'
  
  validates_presence_of :name, :start_date, :period, :period_count
  validates_uniqueness_of :name
  validates_inclusion_of :period, :in => PERIODS
  
  def end_date
    end_date_at(period_count-1)
  end

  Period = Struct.new("Period", :start_date, :end_date)
  def periods
    (0..(period_count-1)).map do |index|
      Period.new(start_date_at(index), end_date_at(index))
    end
  end
  
  private
    def end_date_at(index)
      return start_date_at(index+1) - 1
    end
    
    def start_date_at(index)
      return start_date >> index if period == Budget.month
      return start_date + (index*7) if period == Budget.week
      return start_date >> (index*12) if period == Budget.year
      raise "Unrecognized budget periods #{period}"
    end
end
