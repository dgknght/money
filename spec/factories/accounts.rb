# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account, aliases: [:asset_account] do
    name Faker::Commerce.department
    account_type :asset
    user
    
    factory :equity_account do
      account_type :equity
    end
    
    factory :liability_account do
      account_type :liability
    end
  end
end
