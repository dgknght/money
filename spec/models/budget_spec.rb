require 'spec_helper'

describe Budget do
  let (:entity) { FactoryGirl.create(:entity) }
  
  let (:attributes) do
    {
      entity_id: entity.id,
      name: '2014 budget',
      start_date: '2014-01-01',
      period: Budget.month,
      period_count: 12
    }
  end
  
  it 'is creatable from valid attributes' do
    budget = Budget.new(attributes)
    expect(budget).to be_valid
  end
  
  describe 'name' do
    let (:other_entity) { FactoryGirl.create(:entity, user: entity.user) }
    it 'is required' do
      budget = Budget.new(attributes.without(:name))
      expect(budget).to_not be_valid
    end
    
    it 'is unique for the entity' do
      budget1 = entity.budgets.create!(attributes)
      budget2 = entity.budgets.new(attributes)
      expect(budget2).to have(1).error_on(:name)
    end

    it 'allows the same name to be used for different entities' do
      budget1 = Budget.create!(attributes)
      budget2 = other_entity.budgets.create!(attributes.except(:entity_id))
      expect(budget2).to be_valid
    end
  end
  
  describe 'start_date' do
    it 'is required' do
      budget = Budget.new(attributes.without(:start_date))
      expect(budget).to_not be_valid
    end
  end
  
  describe 'period' do
    it 'defaults to "month"' do
      budget = Budget.new(attributes.without(:period))
      expect(budget).to be_valid
      expect(budget.period).to eq(Budget.month)
    end
    
    it 'is either "year", "month", or "week"' do
      budget = Budget.new(attributes.merge(period: 'notavalidperiod'))
      expect(budget).to_not be_valid
    end
  end
  
  describe 'period_count' do
    it 'defaults to 12' do
      budget = Budget.new(attributes.without(:period_count))
      expect(budget).to be_valid
      expect(budget.period_count).to eq(12)
    end
  end
  
  describe 'end_date' do
    it 'is the end of the last period' do
      budget = Budget.new(attributes)
      expect(budget.end_date).to eq(Date.parse('2014-12-31')      )
    end
  end
  
  describe 'periods' do
    it 'lists the periods in the budget' do
      budget = Budget.new(attributes)
      expect(budget).to have(12).periods
      expect(budget.periods.map{ |p| "#{p.start_date} - #{p.end_date}" }).to match_array [
        '2014-01-01 - 2014-01-31',
        '2014-02-01 - 2014-02-28',
        '2014-03-01 - 2014-03-31',
        '2014-04-01 - 2014-04-30',
        '2014-05-01 - 2014-05-31',
        '2014-06-01 - 2014-06-30',
        '2014-07-01 - 2014-07-31',
        '2014-08-01 - 2014-08-31',
        '2014-09-01 - 2014-09-30',
        '2014-10-01 - 2014-10-31',
        '2014-11-01 - 2014-11-30',
        '2014-12-01 - 2014-12-31'
      ]
    end
  end
  
  describe 'items' do
    let(:budget) { FactoryGirl.create(:budget) }
    let(:item1) { FactoryGirl.create(:budget_item, budget: budget) }
    let(:item2) { FactoryGirl.create(:budget_item, budget: budget) }
    it 'contains the items that belong to the budget' do
      expect(budget.items).to eq([item1, item2])
    end
  end

  describe '#current?' do
    let!(:b2014) { FactoryGirl.create(:budget, entity: entity, name: '2014', start_date: Date.parse('2014-01-01')) }
    let!(:b2015) { FactoryGirl.create(:budget, entity: entity, name: '2015', start_date: Date.parse('2015-01-01')) }
    it 'returns true if the budget is current' do
      Timecop.freeze(Time.parse('2015-02-27 12:00:00 CST')) do
        expect(b2015).to be_current
      end
    end

    it 'returns false if the budget is not current' do
      Timecop.freeze(Time.parse('2015-02-27 12:00:00 CST')) do
        expect(b2014).not_to be_current
      end
    end
  end

  describe '#item_for' do
    let (:budget) { FactoryGirl.create(:budget, entity: entity) }
    let (:dining) { FactoryGirl.create(:account, name: 'Dining', entity: entity, account_type: Account.expense_type) }
    let (:rent) { FactoryGirl.create(:account, name: 'Rent', entity: entity, account_type: Account.expense_type) }
    let!(:item1) { FactoryGirl.create(:budget_item, budget: budget, account: dining) }
    let!(:item2) { FactoryGirl.create(:budget_item, budget: budget, account: rent) }

    it 'returns the budget item associated with the specified account' do
      expect(budget.item_for(dining)).to eq(item1)
    end
  end

  describe '#destroy' do
    let!(:budget) { FactoryGirl.create(:budget) }
    let!(:budget_item) { FactoryGirl.create(:budget_item, budget: budget) }

    it 'removes all constituent budget items' do
      expect{budget.destroy!}.to change(BudgetItem, :count).by(-1)
    end
  end
end
