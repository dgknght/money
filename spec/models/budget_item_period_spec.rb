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

  it 'is creatable from valid attributes' do
    period = BudgetItemPeriod.new(attributes)
    expect(period).to be_valid
  end

  describe 'budget_item_id' do
    it 'is required' do
      period = BudgetItemPeriod.new(attributes.without(:budget_item_id))
      expect(period).not_to be_valid
    end
  end

  describe 'start_date' do
    it 'is required' do
      period = BudgetItemPeriod.new(attributes.without(:start_date))
      expect(period).not_to be_valid
    end
  end

  describe 'budget_amount' do
    it 'is required' do
      period = BudgetItemPeriod.new(attributes.without(:budget_amount))
      expect(period).not_to be_valid
    end
  end

  describe 'actual_amount' do
    let!(:t1) do
      TransactionManager.create(entity, transaction_date: '2013-12-31',
                                        description: 'On the Border',
                                        items_attributes: [
                                          { account_id: checking.id, action: TransactionItem.credit, amount: 50 },
                                          { account_id: dining.id,   action: TransactionItem.debit,  amount: 50 },
                                        ])
    end
    let!(:t2) do
      TransactionManager.create(entity, transaction_date: '2014-01-05',
                                        description: 'Fuddruckers',
                                        items_attributes: [
                                          { account_id: checking.id, action: TransactionItem.credit, amount: 50 },
                                          { account_id: dining.id,   action: TransactionItem.debit,  amount: 50 },
                                        ])
    end
    let!(:t3) do
      TransactionManager.create(entity, transaction_date: '2014-01-25',
                                        description: 'On the Border',
                                        items_attributes: [
                                          { account_id: checking.id, action: TransactionItem.credit, amount: 50 },
                                          { account_id: dining.id,   action: TransactionItem.debit,  amount: 50 },
                                        ])
    end
    let!(:t4) do
      TransactionManager.create(entity, transaction_date: '2014-02-01',
                                        description: 'On the Border',
                                        items_attributes: [
                                          { account_id: checking.id, action: TransactionItem.credit, amount: 50 },
                                          { account_id: dining.id,   action: TransactionItem.debit,  amount: 50 },
                                        ])
    end
    it 'returns the actual amount for the specified account in the specified time' do
      period = BudgetItemPeriod.create!(attributes)
      expect(period.actual_amount).to eq(100)
    end
  end
end
