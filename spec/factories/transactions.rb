# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    transaction_date "2013-09-17"
    description "The Payee"
    entity
    ignore do
      amount 100
      credit_account { FactoryGirl.create(:account, entity: entity) }
      debit_account { FactoryGirl.create(:account, entity: entity) }
    end
    after(:build) do |transaction, evaluator|
      transaction.items << TransactionItem.new(account: evaluator.credit_account, amount: evaluator.amount, action: TransactionItem.credit)
      transaction.items << TransactionItem.new(account: evaluator.debit_account, amount: evaluator.amount, action: TransactionItem.debit)
    end
  end
end
