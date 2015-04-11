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
  has_many :accounts, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :budget_monitors, dependent: :destroy
  has_many :commodities, dependent: :destroy
  has_many :attachment_contents, dependent: :destroy

  # This attribute is here to support the rails form_for helper
  # method in views/entities/new.html.haml. It can be removed
  # if a better workaround is found
  attr_accessor :data

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
