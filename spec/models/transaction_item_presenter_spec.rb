require 'spec_helper'

describe TransactionItemPresenter do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity) }
  let (:salary) { FactoryGirl.create(:income_account, entity: entity) }
  let (:rent) { FactoryGirl.create(:expense_account, entity: entity) }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity) }

  let!(:paycheck1) do
    FactoryGirl.create(:transaction,  transaction_date: '2014-01-01',
                                      amount: 1_000,
                                      description: 'Paycheck',
                                      debit_account: checking,
                                      credit_account: salary)
  end
  let!(:paycheck2) do
    FactoryGirl.create(:transaction,  transaction_date: '2014-01-15',
                                      amount: 1_000,
                                      description: 'Paycheck',
                                      debit_account: checking,
                                      credit_account: salary)
  end
  let!(:rent1) do
    FactoryGirl.create(:transaction,  transaction_date: '2014-01-02',
                                      amount: 800,
                                      description: 'Landlord',
                                      debit_account: rent,
                                      credit_account: checking)
  end
  let!(:groceries1) do
    FactoryGirl.create(:transaction,  transaction_date: '2014-01-12',
                                      amount: 80,
                                      description: 'Market Street',
                                      debit_account: groceries,
                                      credit_account: checking)
  end
  let!(:groceries2) do
    FactoryGirl.create(:transaction,  transaction_date: '2014-01-05',
                                      amount: 80,
                                      description: 'Market Street',
                                      debit_account: groceries,
                                      credit_account: checking)
  end

  it 'should be creatable with an account' do
    presenter = TransactionItemPresenter.new(checking)
    expect(presenter).not_to be_nil
  end

  it 'should enumerate the transaction items in reverse chronological order' do
    presenter = TransactionItemPresenter.new(checking)
    items = presenter.map { |r| r.transaction_item.transaction }.map { |t| [t.description, t.transaction_date] }
    expected = [
      ['Paycheck', Date.parse('2014-01-15') ],
      ['Market Street', Date.parse('2014-01-12') ],
      ['Market Street', Date.parse('2014-01-05') ],
      ['Landlord', Date.parse('2014-01-02') ],
      ['Paycheck', Date.parse('2014-01-01') ]
    ]
    expect(items).to eq(expected)
  end

  it 'should calculate a running balance for each item' do
    presenter = TransactionItemPresenter.new(checking)
    items = presenter.map { |r| [r.balance, r.transaction_item.transaction.transaction_date] }
    expected = [
      [1_040, Date.parse('2014-01-15') ],
      [40, Date.parse('2014-01-12') ],
      [120, Date.parse('2014-01-05') ],
      [200, Date.parse('2014-01-02') ],
      [1_000, Date.parse('2014-01-01') ]
    ]
    expect(items).to eq(expected)
  end
end
