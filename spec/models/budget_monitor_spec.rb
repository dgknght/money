require 'spec_helper'

describe BudgetMonitor do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:dining) { FactoryGirl.create(:account, entity: entity, name: 'Dining', account_type: Account.expense_type) }
  let (:checking) { FactoryGirl.create(:account, entity: entity, name: 'Checking') }
  let (:attributes) do
    {
      account_id: dining.id
    }
  end
  let (:budget) { FactoryGirl.create(:budget, entity: entity, name: '2015', start_date: Date.parse('2015-01-01')) }
  let (:budget_monitor) { FactoryGirl.create(:budget_monitor, account: dining, entity: entity) }
  let!(:budget_item) { FactoryGirl.create(:budget_item, budget: budget, account: dining, budget_amount: 500) }

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
    it 'should return the amount budget for the period, prorated for the number of days that have passed' do
      Timecop.freeze(Time.parse('2015-02-14 12:00:00 CST')) do
        expect(budget_monitor.budget_amount).to eq(250)
      end
    end
  end

  describe '#current_amount' do
    let!(:t1) { FactoryGirl.create(:transaction, transaction_date: '2015-01-31', description: 'III Forks', amount: 100, debit_account: dining, credit_account: checking) }
    let!(:t2) { FactoryGirl.create(:transaction, transaction_date: '2015-02-01', description: 'Nick and Sams', amount: 100, debit_account: dining, credit_account: checking) }
    let!(:t3) { FactoryGirl.create(:transaction, transaction_date: '2015-02-07', description: 'III Forks', amount: 100, debit_account: dining, credit_account: checking) }
    let!(:t4) { FactoryGirl.create(:transaction, transaction_date: '2015-02-15', description: 'III Forks', amount: 100, debit_account: dining, credit_account: checking) }
    it 'should return the amount spent so far this period' do
      Timecop.freeze(Time.parse('2015-02-14 12:00:00 CST')) do
        expect(budget_monitor.current_amount).to eq(200)
      end
    end
  end

  describe '#available_days' do
    it 'should return the total number of days in the period' do
      Timecop.freeze(Time.parse('2015-02-14 12:00:00 CST')) do
        expect(budget_monitor.available_days).to eq(28)
      end
    end
  end

  describe '#past_days' do
    it 'should return the number of days in the period that have already past' do
      Timecop.freeze(Time.parse('2015-02-14 12:00:00 CST')) do
        expect(budget_monitor.past_days).to eq(14)
      end
    end
  end
end
