require 'spec_helper'

describe AccountsPresenter do
  let (:entity) { FactoryGirl.create(:entity) }

  it 'should be creatable from an entity' do
    presenter = AccountsPresenter.new(entity)
    expect(presenter).not_to be_nil
  end

  context 'when no accounts are present' do
    it 'should enumerate empty summary records' do
      presenter = AccountsPresenter.new(entity)
      expect(presenter).to have_account_display_records([
        { caption: 'Assets', balance: 0, depth: 0 },
        { caption: 'Liabilities', balance: 0, depth: 0 },
        { caption: 'Equity', balance: 0, depth: 0 },
        { caption: 'Income', balance: 0, depth: 0 },
        { caption: 'Expense', balance: 0, depth: 0 }
      ])
    end
  end

  context 'when accounts are present' do
    let (:checking) { FactoryGirl.create(:asset_account, name: 'Checking', entity: entity) }
    let (:salary) { FactoryGirl.create(:income_account, name: 'Salary', entity: entity) }
    let!(:paycheck) do
      FactoryGirl.create(:transaction, description: 'Paycheck',
                                       transaction_date: '2014-01-01',
                                       amount: 5_000,
                                       debit_account: checking,
                                       credit_account: salary)
    end

    it 'should enumerate summary records and detail records' do
      presenter = AccountsPresenter.new(entity)
      expect(presenter).to have_account_display_records([
        { caption: 'Assets', balance: 5_000, depth: 0 },
        { caption: 'Checking', balance: 5_000, depth: 1 },
        { caption: 'Liabilities', balance: 0, depth: 0 },
        { caption: 'Equity', balance: 5_000, depth: 0 },
        { caption: 'Retained earnings', balance: 5_000, depth: 1 },
        { caption: 'Income', balance: 5_000, depth: 0 },
        { caption: 'Salary', balance: 5_000, depth: 1 },
        { caption: 'Expense', balance: 0, depth: 0 }
      ])
    end
  end
end
