# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    transaction_date "2013-09-17"
    description "The Payee"
    user
    after(:build) do |transaction, evaluator|
      transaction.items << TransactionItem.new(account: FactoryGirl.create(:account), amount: 100, action: :credit)
      transaction.items << TransactionItem.new(account: FactoryGirl.create(:account), amount: 100, action: :debit)
    end
  end
end
