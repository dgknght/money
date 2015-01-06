require 'spec_helper'

describe BudgetMonitor do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:account) { FactoryGirl.create(:account, entity: entity) }
  let (:attributes) do
    {
      account_id: account.id
    }
  end

  it 'should be creatable from valid attributes' do
    monitor = entity.budget_monitors.new(attributes)
    expect(monitor).to be_valid
  end

  describe '#account_id' do
    it 'should be required' do
      monitor = entity.budget_monitors.new(attributes.except(:account_id))
      expect(monitor).not_to be_valid
      expect(monitor).to have(1).error_on(:account_id)
    end
  end

  describe '#budget_amount' do
    let (:budget) { FactoryGirl.create(:budget, entity: entity, start_date: Date.parse('2015-01-01')) }
    let (:budget_monitor) { FactoryGirl.create(:budget_monitor, account: account, entity: entity) }
    let (:budget_item) { FactoryGirl.create(:budget_item, budget: budget, account: account) }
    let!(:budget_item_period) { FactoryGirl.create(:budget_item_period, budget_item: budget_item, start_date: Date.parse('2015-02-01'), budget_amount: 500) }
    it 'should return the amount budget for the period, prorated for the number of days that have passed' do
      Timecop.freeze(Date.parse('2015-02-14')) do
        expect(budget_monitor.budget_amount).to eq(250)
      end
    end
  end
end
