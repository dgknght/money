# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attachment do
    transaction_id 1
    name "MyText"
    content_type "MyText"
  end
end
