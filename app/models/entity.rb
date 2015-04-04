# == Schema Information
#
# Table name: entities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  name       :string(100)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Entity < ActiveRecord::Base
  validates_presence_of :name, :user_id
  
  belongs_to :user
  has_many :accounts, dependent: :delete_all
  has_many :transactions, dependent: :delete_all
  has_many :budgets, dependent: :delete_all
  has_many :budget_monitors, dependent: :delete_all
  has_many :commodities, dependent: :delete_all
  has_many :attachment_contents, dependent: :delete_all

  def current_budget
    today = Date.today
    budgets.where(['start_date <= ?', today]).select{|b| b.end_date > today}.first
  end

  # Returns the unrealized gains in the commodities held by the entity
  # as of the specified date
  def unrealized_gains
    accounts.commodities.reduce(0) {|sum, account| sum + account.gains_with_children}
  end

  def unrealized_gains_as_of(date)
    accounts.commodities.reduce(0) {|sum, account| sum + account.gains_with_children_as_of(date)}
  end
end
