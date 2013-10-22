# == Schema Information
#
# Table name: budgets
#
#  id         :integer          not null, primary key
#  entity_id  :integer          not null
#  name       :string(255)      not null
#  start_date :date             not null
#  end_date   :date             not null
#  created_at :datetime
#  updated_at :datetime
#

class Budget < ActiveRecord::Base
  belongs_to :entity
  has_many :items, class_name: 'BudgetItem'
  
  validates_presence_of :name, :start_date, :end_date
  validates_uniqueness_of :name
  validate :end_date_must_follow_start_date
  
  private
    def end_date_must_follow_start_date
      if end_date && start_date
        errors.add(:end_date, "must be after the start date") unless end_date > start_date
      end
    end
end
