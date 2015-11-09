require 'spec_helper'

describe BudgetItem do
  let(:entity) { FactoryGirl.create(:entity) }
  let(:budget) { FactoryGirl.create(:budget, entity: entity, start_date: Date.parse('2015-01-01')) }
  let(:salary) { FactoryGirl.create(:income_account, entity: entity) }
  let(:groceries) { FactoryGirl.create(:expense_account, entity: entity) }
  let(:attributes) do
    {
      budget_id: budget.id,
      account_id: groceries.id
    }
  end

  it 'is creatable from valid attributes' do
    item = BudgetItem.new(attributes)
    expect(item).to be_valid
  end

  describe 'budget_id' do
    it 'is required' do
      item = BudgetItem.new(attributes.without(:budget_id))
      expect(item).to_not be_valid
    end
  end

  describe 'budget' do
    it 'references the budget to which the item belongs' do
      item = BudgetItem.new(attributes)
      expect(item.budget).to eq(budget)
    end
  end

  describe 'account_id' do
    it 'is required' do
      item = BudgetItem.new(attributes.without(:account_id))
      expect(item).to_not be_valid
    end

    it 'is unique within a given budget' do
      item = BudgetItem.create!(attributes)
      item2 = BudgetItem.new(attributes)
      expect(item).to be_valid
      expect(item2).to_not be_valid
    end
  end

  describe 'account' do
    it 'references the account for which amounts are specified' do
      item = BudgetItem.new(attributes)
      expect(item.account).to eq(groceries)
    end
  end

  describe 'periods' do
    it 'contains a list of the periods within the budget' do
      item = budget.items.create(attributes)
      expect(item.periods).to_not be_nil
      start_dates = (1..12).map{|m| Date.parse("2015-%02d-01" % m)}
      expect(item.periods.map{|p| p.start_date}).to eq(start_dates)
    end
  end

  describe 'scope' do
    let!(:salary_item) { FactoryGirl.create(:budget_item, budget: budget, account: salary) }
    let!(:groceries_item) { FactoryGirl.create(:budget_item, budget: budget, account: groceries) }

    describe 'income' do
      it 'returns budget items for income accounts' do
        expect(budget.items.income).to eq([salary_item])
      end
    end

    describe 'expense' do
      it 'returns budget items for expense accounts' do
        expect(budget.items.expense).to eq([groceries_item])
      end
    end
  end

  describe '#current_period' do
    let (:budget_item) { FactoryGirl.create(:budget_item, budget: budget, account: groceries) }
    it 'returns the period within the budget item in which the current date falls' do
      Timecop.freeze(Date.parse('2015-02-27')) do
        expect(budget_item.current_period).not_to be_nil
        expect(budget_item.current_period.start_date).to eq(Date.parse('2015-02-01'))
      end
    end

    it 'returns nil if the budget to which the item belongs is not current' do
      Timecop.freeze(Date.parse('2001-02-27')) do
        expect(budget_item.current_period).to be_nil
      end
    end
  end
end
