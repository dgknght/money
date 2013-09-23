# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    transaction_date "2013-09-17"
    description "The Payee"
    entity
    after(:build) do |transaction, evaluator|
      transaction.items << TransactionItem.new(account: FactoryGirl.create(:account), amount: 100, action: TransactionItem.credit)
      transaction.items << TransactionItem.new(account: FactoryGirl.create(:account), amount: 100, action: TransactionItem.debit)
    end
  end
end
