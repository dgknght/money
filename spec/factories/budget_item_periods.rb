# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :budget_item_period do
    budget_item
    start_date '2013-10-24'
    budget_amount 9.99
  end
end
