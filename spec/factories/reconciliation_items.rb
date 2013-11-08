# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reconciliation_item do
    transaction_item
    reconciliation { FactoryGirl.create(:reconciliation, closing_balance: transaction_item.amount) }
  end
end
