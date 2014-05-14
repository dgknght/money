# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lot do
    account
    commodity
    price 9.99
    shares_owned 100
    purchase_date "2014-05-13"
  end
end
