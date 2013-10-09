require 'spec_helper'

describe IncomeStatementReport do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Checking') }
  let (:home) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Home') }
  let (:savings) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Savings') }
  let (:car) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Car', parent_id: savings.id) }
  let (:reserve) { FactoryGirl.create(:asset_account, entity_id: entity.id, name: 'Reserve', parent_id: savings.id) }
  
  let (:credit_card) { FactoryGirl.create(:liability_account, entity_id: entity.id, name: 'Credit Card') }
  let (:home_loan) { FactoryGirl.create(:liability_account, entity_id: entity.id, name: 'Home Loan') }
  
  let (:opening_balances) { FactoryGirl.create(:equity_account, entity_id: entity.id, name: 'Opening Balances') }

  let (:salary) { FactoryGirl.create(:income_account, entity_id: entity.id, name: 'Salary') }
  let (:gifts) { FactoryGirl.create(:income_account, entity_id: entity.id, name: 'Gifts') }
  
  let (:dining) { FactoryGirl.create(:expense_account, entity_id: entity.id, name: 'Dining') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity_id: entity.id, name: 'Groceries') }
  let (:mortgage_interest) { FactoryGirl.create(:expense_account, entity_id: entity.id, name: 'Mortgage Interest') }
  
  let!(:checking_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: opening_balances.id, amount: 2000}, 
                                  {action: TransactionItem.debit, account_id: checking.id, amount: 2000}
                                ])
  end
  let!(:home_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: opening_balances.id, amount: 200000}, 
                                  {action: TransactionItem.debit, account_id: home.id, amount: 200000}
                                ])
  end
  let!(:car_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: opening_balances.id, amount: 10000}, 
                                  {action: TransactionItem.debit, account_id: car.id, amount: 10000}
                                ])
  end
  let!(:reserve_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: opening_balances.id, amount: 30000}, 
                                  {action: TransactionItem.debit, account_id: reserve.id, amount: 30000}
                                ])
  end
  let!(:credit_card_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 2000}, 
                                  {action: TransactionItem.debit, account_id: opening_balances.id, amount: 2000}
                                ])
  end
  let!(:home_loan_opening) do
    entity.transactions.create!(transaction_date: '2012-12-31', 
                                description: 'opening balances', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: home_loan.id, amount: 175000}, 
                                  {action: TransactionItem.debit, account_id: opening_balances.id, amount: 175000}
                                ])
  end
  let!(:salary_1) do
    entity.transactions.create!(transaction_date: '2013-01-01', 
                                description: 'The Factory', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: salary.id, amount: 3000}, 
                                  {action: TransactionItem.debit, account_id: checking.id, amount: 3000}
                                ])
  end
  let!(:salary_2) do
    entity.transactions.create!(transaction_date: '2013-01-15', 
                                description: 'The Factory', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: salary.id, amount: 3000}, 
                                  {action: TransactionItem.debit, account_id: checking.id, amount: 3000}
                                ])
  end
  let!(:salary_3) do
    entity.transactions.create!(transaction_date: '2013-02-01', 
                                description: 'The Factory', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: salary.id, amount: 3000}, 
                                  {action: TransactionItem.debit, account_id: checking.id, amount: 3000}
                                ])
  end
  let!(:salary_4) do
    entity.transactions.create!(transaction_date: '2013-02-15', 
                                description: 'The Factory', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: salary.id, amount: 3000}, 
                                  {action: TransactionItem.debit, account_id: checking.id, amount: 3000}
                                ])
  end
  let!(:gifts_1) do
    entity.transactions.create!(transaction_date: '2013-02-27', 
                                description: 'Mom', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: gifts.id, amount: 100}, 
                                  {action: TransactionItem.debit, account_id: checking.id, amount: 100}
                                ])
  end
  let!(:groceries_1) do
    entity.transactions.create!(transaction_date: '2013-01-06', 
                                description: 'Kroger', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: checking.id, amount: 50}, 
                                  {action: TransactionItem.debit, account_id: groceries.id, amount: 50}
                                ])
  end
  let!(:groceries_2) do
    entity.transactions.create!(transaction_date: '2013-01-13', 
                                description: 'Kroger', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 50}, 
                                  {action: TransactionItem.debit, account_id: groceries.id, amount: 50}
                                ])
  end
  let!(:groceries_3) do
    entity.transactions.create!(transaction_date: '2013-01-20', 
                                description: 'Kroger', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 50}, 
                                  {action: TransactionItem.debit, account_id: groceries.id, amount: 50}
                                ])
  end
  let!(:groceries_4) do
    entity.transactions.create!(transaction_date: '2013-01-27', 
                                description: 'Kroger', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 50}, 
                                  {action: TransactionItem.debit, account_id: groceries.id, amount: 50}
                                ])
  end
  let!(:groceries_5) do
    entity.transactions.create!(transaction_date: '2013-02-03', 
                                description: 'Kroger', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 50}, 
                                  {action: TransactionItem.debit, account_id: groceries.id, amount: 50}
                                ])
  end
  let!(:groceries_6) do
    entity.transactions.create!(transaction_date: '2013-02-10', 
                                description: 'Kroger', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 50}, 
                                  {action: TransactionItem.debit, account_id: groceries.id, amount: 50}
                                ])
  end
  let!(:groceries_7) do
    entity.transactions.create!(transaction_date: '2013-02-17', 
                                description: 'Kroger', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 50}, 
                                  {action: TransactionItem.debit, account_id: groceries.id, amount: 50}
                                ])
  end
  let!(:groceries_8) do
    entity.transactions.create!(transaction_date: '2013-02-24', 
                                description: 'Kroger', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 50}, 
                                  {action: TransactionItem.debit, account_id: groceries.id, amount: 50}
                                ])
  end
  
  let!(:dining_1) do
    entity.transactions.create!(transaction_date: '2013-01-5', 
                                description: 'Mooyah', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: credit_card.id, amount: 25}, 
                                  {action: TransactionItem.debit, account_id: dining.id, amount: 25}
                                ])
  end
  
  let!(:credit_card_1) do
    entity.transactions.create!(transaction_date: '2013-01-4', 
                                description: 'Citibank', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: checking.id, amount: 100}, 
                                  {action: TransactionItem.debit, account_id: credit_card.id, amount: 100}
                                ])
  end
  let!(:credit_card_1) do
    entity.transactions.create!(transaction_date: '2013-02-4', 
                                description: 'Citibank', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: checking.id, amount: 100}, 
                                  {action: TransactionItem.debit, account_id: credit_card.id, amount: 100}
                                ])
  end
  
  let!(:mortgage_1) do
    entity.transactions.create!(transaction_date: '2013-01-2', 
                                description: 'Quicken Loans', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: checking.id, amount: 1000}, 
                                  {action: TransactionItem.debit, account_id: home_loan.id, amount: 100}, 
                                  {action: TransactionItem.debit, account_id: mortgage_interest.id, amount: 900}
                                ])
  end
  let!(:mortgage_2) do
    entity.transactions.create!(transaction_date: '2013-02-2', 
                                description: 'Quicken Loans', 
                                items_attributes: [
                                  {action: TransactionItem.credit, account_id: checking.id, amount: 1000}, 
                                  {action: TransactionItem.debit, account_id: home_loan.id, amount: 101}, 
                                  {action: TransactionItem.debit, account_id: mortgage_interest.id, amount: 899}
                                ])
  end
  
  it 'should render an income statement' do
    report = IncomeStatementReport.new(entity, from: '2013-01-01', to: '2013-01-31')
    report.content.should == [
      { account: 'Income',            balance: '6,000.00', depth: 0 },
      { account: 'Gifts',             balance:     '0.00', depth: 1 },
      { account: 'Salary',            balance: '6,000.00', depth: 1 },
      { account: 'Expense',           balance: '1,125.00', depth: 0 },
      { account: 'Dining',            balance:    '25.00', depth: 1 },
      { account: 'Groceries',         balance:   '200.00', depth: 1 },
      { account: 'Mortgage Interest', balance:   '900.00', depth: 1 },
      { account: 'Net',               balance: '4,875.00', depth: 0 }
    ]
  end
end