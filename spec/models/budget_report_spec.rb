require 'spec_helper'
require 'ostruct'

describe BudgetReport do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:filter) { BudgetFilter.new(start_date: '2013-01-01', end_date: '2013-01-31') }

  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'Salary') }
  let (:rent) { FactoryGirl.create(:expense_account, entity: entity, name: 'Rent') }
  
  let (:budget) do
    result = entity.budgets.create!(name: '2013', start_date: '2013-01-01', period: Budget.month, period_count: 12)

    item = result.items.new(account_id: salary.id)
    distributor = BudgetItemDistributor.new(item)
    distributor.apply_attributes(method: BudgetItemDistributor.average, options: { amount: 10_000 })
    distributor.distribute
    item.save!

    item = result.items.new(account_id: rent.id)
    distributor = BudgetItemDistributor.new(item)
    distributor.apply_attributes(method: BudgetItemDistributor.average, options: { amount: 1_100 })
    distributor.distribute
    item.save!

    result
  end

  let!(:t1) { FactoryGirl.create(:transaction, transaction_date: '2013-01-01', entity: entity,
					       items_attributes: [
						 { action: TransactionItem.credit, account_id: salary.id, amount: 5_000 },
						 { action: TransactionItem.debit, account_id: checking.id, amount: 5_000 }
					       ])}
  let!(:t2) { FactoryGirl.create(:transaction, transaction_date: '2013-01-15', entity: entity,
					       items_attributes: [
						 { action: TransactionItem.credit, account_id: salary.id, amount: 4_900 },
						 { action: TransactionItem.debit, account_id: checking.id, amount: 4_900 }
					       ])}
  let!(:t3) { FactoryGirl.create(:transaction, transaction_date: '2013-01-5', entity: entity,
					       items_attributes: [
						 { action: TransactionItem.credit, account_id: checking.id, amount: 1_200 },
						 { action: TransactionItem.debit, account_id: rent.id, amount: 1_200 }
					       ])}

  it 'should be creatable given a budget and a filter' do
    report = BudgetReport.new(budget, filter)
    expect(report).not_to be_nil
  end

  describe 'content' do
    it 'has the correct report rows' do
      report = BudgetReport.new(budget, filter)
      expected = [
        OpenStruct.new(account: 'Income' , budget_amount: '10,000.00', actual_amount:  '9,900.00', difference: '-100.00', percent_difference: '-1.0%', actual_per_month:  '9,900.00', evaluation: 'negative', row_type: 'report_header'),
        OpenStruct.new(account: 'Salary' , budget_amount: '10,000.00', actual_amount:  '9,900.00', difference: '-100.00', percent_difference: '-1.0%', actual_per_month:  '9,900.00', evaluation: 'negative', row_type: nil),
        OpenStruct.new(account: 'Expense', budget_amount: '-1,100.00', actual_amount: '-1,200.00', difference: '-100.00', percent_difference: '-9.1%', actual_per_month: '-1,200.00', evaluation: 'negative', row_type: 'report_header'),
        OpenStruct.new(account: 'Rent'   , budget_amount: '-1,100.00', actual_amount: '-1,200.00', difference: '-100.00', percent_difference: '-9.1%', actual_per_month: '-1,200.00', evaluation: 'negative', row_type: nil),
        OpenStruct.new(account: 'Net'    , budget_amount: '8,900.00' , actual_amount:  '8,700.00', difference: '-200.00', percent_difference: '-2.2%', actual_per_month:  '8,700.00', evaluation: 'negative', row_type: 'report_header')
      ]
      expect(report.content).to have(5).items
      expect(report.content[0]).to eq(expected[0])
      expect(report.content[1]).to eq(expected[1])
      expect(report.content[2]).to eq(expected[2])
      expect(report.content[3]).to eq(expected[3])
      expect(report.content[4]).to eq(expected[4])
    end
  end
end
