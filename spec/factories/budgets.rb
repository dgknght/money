# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :budget do
    entity
    name { Faker::Commerce.department }
    start_date '2014-01-01'
    period Budget.month
    period_count 12
  end
end
