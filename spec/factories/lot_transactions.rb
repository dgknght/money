# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lot_transaction do
    lot_id 1
    transaction_id 1
    shares_traded "9.99"
    price "9.99"
  end
end
