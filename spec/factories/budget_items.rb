FactoryGirl.define do
  factory :budget_item do
    ignore do
      budget_amount 100
    end
    
    budget
    account
    
    after(:build) do |budget_item, evaluator|
      budget_item.sync_periods
      budget_item.periods.each { |p| p.budget_amount = evaluator.budget_amount }
    end
  end
end