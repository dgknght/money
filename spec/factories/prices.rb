# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :price do
    commodity_id 1
    trade_date "2014-04-23"
    price "9.99"
  end
end
