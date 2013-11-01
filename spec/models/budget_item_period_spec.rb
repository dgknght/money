require 'spec_helper'

describe BudgetItemPeriod do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:budget) { FactoryGirl.create(:budget, entity: entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity) }
  let (:dining) { FactoryGirl.create(:expense_account, entity: entity) }
  let (:budget_item) { FactoryGirl.create(:budget_item, budget: budget, account: dining) }
  let (:attributes) do
    {
      budget_item_id: budget_item.id,
      start_date: '2014-01-01',
      budget_amount: 100
    }
  end
  
  it 'should be creatable from valid attributes' do
    period = BudgetItemPeriod.new(attributes)
    period.should be_valid
  end
  
  describe 'budget_item_id' do
    it 'should be required' do
      period = BudgetItemPeriod.new(attributes.without(:budget_item_id))
      period.should_not be_valid
    end
  end  
 
  describe 'start_date' do
    it 'should be required' do
      period = BudgetItemPeriod.new(attributes.without(:start_date))
      period.should_not be_valid
    end
  end  
 
  describe 'budget_amount' do
    it 'should be required' do
      period = BudgetItemPeriod.new(attributes.without(:budget_amount))
      period.should_not be_valid
    end
  end  

  describe 'actual_amount' do
    let!(:t1) { FactoryGirl.create(:transaction, transaction_date: '2013-12-31', entity: entity,
						items_attributes: [
						  { account_id: checking.id, action: TransactionItem.credit, amount: 50 },
						  { account_id: dining.id,   action: TransactionItem.debit,  amount: 50 },
						])}
    let!(:t2) { FactoryGirl.create(:transaction, transaction_date: '2014-01-05', entity: entity,
						items_attributes: [
						  { account_id: checking.id, action: TransactionItem.credit, amount: 50 },
						  { account_id: dining.id,   action: TransactionItem.debit,  amount: 50 },
						])}
    let!(:t3) { FactoryGirl.create(:transaction, transaction_date: '2014-01-25', entity: entity,
						items_attributes: [
						  { account_id: checking.id, action: TransactionItem.credit, amount: 50 },
						  { account_id: dining.id,   action: TransactionItem.debit,  amount: 50 },
						])}
    let!(:t4) { FactoryGirl.create(:transaction, transaction_date: '2014-02-01', entity: entity,
						items_attributes: [
						  { account_id: checking.id, action: TransactionItem.credit, amount: 50 },
						  { account_id: dining.id,   action: TransactionItem.debit,  amount: 50 },
						])}
    it 'should return the actual amount for the specified account in the specified time' do
      period = BudgetItemPeriod.create!(attributes)
      period.actual_amount.should == 100
    end
  end
end
