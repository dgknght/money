# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction_item do
    association :owning_transaction, factory: :transaction
    account
    action TransactionItem.debit
    memo { Faker::Lorem.sentence(3) }
    confirmation { Faker::Code.isbn }
    amount 100
    reconciled false
  end
end
