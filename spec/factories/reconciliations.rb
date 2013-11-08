# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reconciliation do
    account
    reconciliation_date '2013-01-31'
    closing_balance 1_000
    
    before(:create) do |reconciliation, evaluator| 
      unless reconciliation.balance_difference == 0
        reconciliation << FactoryGirl.create(:transaction_item, amount: reconciliation.balance_difference, account: reconciliation.account)
      end
    end
  end
end
