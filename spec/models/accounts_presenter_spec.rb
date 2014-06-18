require 'spec_helper'

describe AccountsPresenter do
  let (:entity) { FactoryGirl.create(:entity) }

  it 'should be creatable from an entity' do
    presenter = AccountsPresenter.new(entity)
    expect(presenter).not_to be_nil
  end

  context 'when no accounts are present' do
    it 'should enumerate empty summary records' do
      presenter = AccountsPresenter.new(entity.accounts)
      records = presenter.map { |r| [r.caption, r.balance] }
      expect(records).to eq([
        ['Assets', 0],
        ['Liabilities', 0],
        ['Equity', 0],
        ['Income', 0],
        ['Expense', 0],
      ])
    end
  end

  context 'when accounts are present' do
    it 'should enumerate summary records and detail records'
  end
end
