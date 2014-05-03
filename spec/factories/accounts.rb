# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account, aliases: [:asset_account] do
    name { Faker::Commerce.department }
    account_type Account.asset_type
    entity
    
    factory :equity_account do
      account_type Account.equity_type
    end
    
    factory :liability_account do
      account_type Account.liability_type
    end
    
    factory :income_account do
      account_type Account.income_type
    end
    
    factory :expense_account do
      account_type Account.expense_type
    end

    factory :commodity_account do
      content_type Account.commodity_content
    end
  end
end
