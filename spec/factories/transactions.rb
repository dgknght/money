# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    transaction_date "2013-09-17"
    description "The Payee"
    memo { Faker::Lorem.sentence(3) }
    confirmation { Faker::Code.isbn }
    entity
    ignore do
      amount 100
      credit_account { FactoryGirl.create(:account, entity: entity) }
      debit_account { FactoryGirl.create(:account, entity: entity) }
    end
    after(:build) do |transaction, evaluator|
      transaction.items.build(account: evaluator.credit_account, amount: evaluator.amount, action: TransactionItem.credit)
      transaction.items.build(account: evaluator.debit_account, amount: evaluator.amount, action: TransactionItem.debit)
    end
  end
end
