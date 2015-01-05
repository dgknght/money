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
end
