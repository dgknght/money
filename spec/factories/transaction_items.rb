# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction_item do
    transaction
    account
    action :debit
    amount 100
  end
end
