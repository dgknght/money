# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reconciliation do
    account
    reconciliation_date '2013-01-31'
    closing_balance 1_000
  end
end
