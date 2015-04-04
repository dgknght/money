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
    
    def all_periods
      PERIODS
    end
  end
  
  belongs_to :entity
  has_many :items, class_name: 'BudgetItem', dependent: :destroy
  
  validates_presence_of :name, :start_date, :period, :period_count
  validates_uniqueness_of :name, scope: :entity_id
  validates_inclusion_of :period, :in => PERIODS
  
  after_update :sync_budget_item_periods
  
  def current?
    Date.today >= start_date && Date.today <= end_date
  end

  def end_date
    end_date_at(period_count-1)
  end

  def item_for(account)
    id = account.is_a?(Account) ? account.id : account
    items.where(account_id: id).first
  end

  Period = Struct.new("Period", :start_date, :end_date)
  def periods
    (0..(period_count-1)).map do |index|
      Period.new(start_date_at(index), end_date_at(index))
    end
  end
  
  private
    def end_date_at(index)
      return nil if start_date.nil?
      return start_date_at(index+1) - 1
    end
    
    def start_date_at(index)
      return nil if start_date.nil?
      return start_date >> index if period == Budget.month
      return start_date + (index*7) if period == Budget.week
      return start_date >> (index*12) if period == Budget.year
      raise "Unrecognized budget periods #{period}"
    end
    
    def sync_budget_item_periods
      items.each { |item| item.sync_periods }
    end
end
