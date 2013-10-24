# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :budget do
    entity
    name { Faker::Commerce.department }
    start_date { '2014-01-01' }
    end_date { '2014-12-31' }
  end
end
