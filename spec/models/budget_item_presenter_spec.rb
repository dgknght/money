require 'spec_helper'

describe BudgetItemPresenter do
  let(:budget) { FactoryGirl.create(:budget) }
  let(:account) { FactoryGirl.create(:expense_account, entity: budget.entity) }

  let(:attributes) do
    {
      account_id: account.id,
      method: :average,
      amount: 350
    }
  end
  
  it 'should be creatable with an existing budget and valid attributes' do
    presenter = BudgetItemPresenter.new(budget, attributes)
    presenter.should be_valid
  end
  
  describe 'method' do
    it 'should be required' do
      presenter = BudgetItemPresenter.new(budget, attributes.without(:method))
      presenter.should_not be_valid
    end
  end
  
  describe 'account_id' do
    it 'should be required' do
      presenter = BudgetItemPresenter.new(budget, attributes.without(:account_id))
      presenter.should_not be_valid
    end
  end
  
  describe 'average method' do
    it 'should fill each period within the budget with the specified value' do
      presenter = BudgetItemPresenter.new(budget, attributes)
      budget_item = presenter.budget_item
      budget_item.should_not be_nil
      budget_item.periods.map { |period| period.budget_amount }.should == 1..12.map { |index| 350 }
    end
  end
end