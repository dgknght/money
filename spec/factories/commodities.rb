# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :commodity do
    entity
    name  { Faker::Company.name }
    symbol { Faker::Address.state_abbr }
    market Commodity.nyse
  end
end
