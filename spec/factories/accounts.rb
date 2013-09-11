# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account do
    name Faker::Commerce.department
    account_type Account.asset
    user
  end
end
