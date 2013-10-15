# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :budget do
    entity
    name { Faker::Commerce.department }
    start_date { Date.today }
    end_date { (start_date >> 12) - 1 }
  end
end
