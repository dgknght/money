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
  
  it 'should be creatable from valid attributes' do
    presenter = BudgetItemPresenter.new(attributes)
    presenter.should be_valid
  end
  
  describe 'method' do
    it 'should be required' do
      presenter = BudgetItemPresenter.new(attributes.without(:method))
      presenter.should_not be_valid
    end
  end
end