# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attachment do
    transaction
    name "SomeImportantFile"
    content_type "text/html"
    size 1024
  end
end
