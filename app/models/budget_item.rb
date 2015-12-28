# == Schema Information
#
# Table name: budget_items
#
#  id         :integer          not null, primary key
#  budget_id  :integer          not null
#  account_id :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class BudgetItem < ActiveRecord::Base
  belongs_to :budget, inverse_of: :items
  belongs_to :account, inverse_of: :budget_items
  has_many :periods, class_name: BudgetItemPeriod, inverse_of: :budget_item, validate: false, autosave: true, dependent: :destroy
  
  accepts_nested_attributes_for :periods, allow_destroy: true

  validates_presence_of :budget_id, :account_id
  validates_uniqueness_of :account_id, scope: :budget_id
  
  before_validation :sync_periods
  
  scope :income, -> { joins(:account).where('accounts.account_type=?', Account.income_type) }
  scope :expense, -> { joins(:account).where('accounts.account_type=?', Account.expense_type) }

  def as_json(options = nil)
    super({include: :periods}.merge(options))
  end

  def current_period
    @current_period ||= get_current_period
  end

  def sync_periods
    return unless budget
    
    budget.periods.each_with_index do |p, i|
      if periods.length <= i
        period = periods.build(start_date: p.start_date, budget_amount: 0)
      else
        period = periods[i]
        period.start_date = p.start_date
      end
    end
  end

  private

  def current_period_index
    now = Date.today
    budget.periods.find_index{|p| p.start_date <= now && p.end_date >= now}
  end

  def get_current_period
    index = current_period_index
    index ? periods[index] : nil
  end
end
