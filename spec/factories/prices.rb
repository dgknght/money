# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :price do
    commodity
    trade_date { Date.today }
    price 5.4321
  end
end
