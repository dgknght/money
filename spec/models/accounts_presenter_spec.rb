require 'spec_helper'

describe AccountsPresenter do
  let (:entity) { FactoryGirl.create(:entity) }

  shared_context 'accounts' do
    let!(:checking) { FactoryGirl.create(:asset_account, name: 'Checking', entity: entity) }
    let!(:savings) { FactoryGirl.create(:asset_account, name: 'Savings', entity: entity) }
    let!(:car_savings) { FactoryGirl.create(:asset_account, name: 'Car', entity: entity, parent: savings) }
    let!(:reserve_savings) { FactoryGirl.create(:asset_account, name: 'Reserve', entity: entity, parent: savings) }
    let!(:opening_balances) { FactoryGirl.create(:equity_account, name: 'Opening balances', entity: entity) }
    let!(:salary) { FactoryGirl.create(:income_account, name: 'Salary', entity: entity) }
  end

  shared_context 'transactions' do
    let!(:paycheck) do
      FactoryGirl.create(:transaction, description: 'Paycheck',
                                       transaction_date: '2014-01-01',
                                       amount: 5_000,
                                       debit_account: checking,
                                       credit_account: salary)
    end
    let!(:open_car_savings) do
      FactoryGirl.create(:transaction, description: 'Opening balance',
                                       transaction_date: '2014-01-01',
                                       amount: 6_000,
                                       debit_account: car_savings,
                                       credit_account: opening_balances)
    end
    let!(:open_reserve_savings) do
      FactoryGirl.create(:transaction, description: 'Opening balance',
                                       transaction_date: '2014-01-01',
                                       amount: 24_000,
                                       debit_account: reserve_savings,
                                       credit_account: opening_balances)
    end
  end

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
    include_context 'accounts'
    include_context 'transactions'

    it 'should enumerate summary records and detail records' do
      entity.recalculate_all_account_balances
      presenter = AccountsPresenter.new(entity)
      expect(presenter).to have_account_display_records([
        { caption: 'Assets', balance: 35_000, depth: 0 },
        { caption: 'Checking', balance: 5_000, depth: 1 },
        { caption: 'Savings', balance: 30_000, depth: 1 },
        { caption: 'Car', balance: 6_000, depth: 2 },
        { caption: 'Reserve', balance: 24_000, depth: 2 },

        { caption: 'Liabilities', balance: 0, depth: 0 },

        { caption: 'Equity', balance: 35_000, depth: 0 },
        { caption: 'Opening balances', balance: 30_000, depth: 1 },
        { caption: 'Retained earnings', balance: 5_000, depth: 1 },

        { caption: 'Income', balance: 5_000, depth: 0 },
        { caption: 'Salary', balance: 5_000, depth: 1 },

        { caption: 'Expense', balance: 0, depth: 0 }
      ])
    end

    describe '#hide_zero_balances' do
      let!(:rent) { FactoryGirl.create(:expense_account, entity: entity, name: 'Rent') }

      it 'should cause accounts with zero balance not to be displayed when true' do
        entity.recalculate_all_account_balances
        presenter = AccountsPresenter.new(entity, hide_zero_balances: true)
        expect(presenter).to have_account_display_records([
          { caption: 'Assets', balance: 35_000, depth: 0 },
          { caption: 'Checking', balance: 5_000, depth: 1 },
          { caption: 'Savings', balance: 30_000, depth: 1 },
          { caption: 'Car', balance: 6_000, depth: 2 },
          { caption: 'Reserve', balance: 24_000, depth: 2 },

          { caption: 'Liabilities', balance: 0, depth: 0 },

          { caption: 'Equity', balance: 35_000, depth: 0 },
          { caption: 'Opening balances', balance: 30_000, depth: 1 },
          { caption: 'Retained earnings', balance: 5_000, depth: 1 },

          { caption: 'Income', balance: 5_000, depth: 0 },
          { caption: 'Salary', balance: 5_000, depth: 1 },

          { caption: 'Expense', balance: 0, depth: 0 }
        ])
      end
    end

    context 'and investment accounts are present' do
      let!(:ira) { FactoryGirl.create(:commodities_account, name: 'IRA', entity: entity) }
      let!(:lt_grains) { FactoryGirl.create(:income_account, name: 'Long-term capital gains', entity: entity) }
      let!(:st_grains) { FactoryGirl.create(:income_account, name: 'Short-term capital gains', entity: entity) }
      let!(:kss) { FactoryGirl.create(:commodity, symbol: 'KSS', name: 'Knight Software Services', entity: entity) }
      let!(:open_ira) do
        FactoryGirl.create(:transaction, description: 'Opening balance',
                                        transaction_date: '2014-01-01',
                                        amount: 1_500,
                                        debit_account: ira,
                                        credit_account: opening_balances)
      end
      before(:all) { Timecop.freeze('2014-06-01') }
      after(:all) { Timecop.return }
      before(:each) do
        CommodityTransactionCreator.new(
          account: ira,
          action: CommodityTransactionCreator.buy,
          symbol: 'KSS',
          shares: 100,
          value: 1_000,
          transaction_date: '2014-01-02'
        ).create!
        CommodityTransactionCreator.new(
          account: ira,
          action: CommodityTransactionCreator.sell,
          symbol: 'KSS',
          shares: 50,
          value: 600,
          transaction_date: '2014-02-02'
        ).create!
      end

      # [{ caption: 'Assets'                  , balance: 36_700, depth: 0 },
      #  { caption: 'Checking'                , balance:  5_000, depth: 1 },
      #  { caption: 'IRA'                     , balance:  1_700, depth: 1 },
      #  { caption: 'Savings'                 , balance: 30_000, depth: 1 },
      #  { caption: 'Car'                     , balance:  6_000, depth: 2 },
      #  { caption: 'Reserve'                 , balance: 24_000, depth: 2 },
      #  { caption: 'Liabilities'             , balance:      0, depth: 0 },

      #  { caption: 'Equity'                  , balance: 36_700, depth: 0 },
      #  { caption: 'Opening balances'        , balance: 31_500, depth: 1 },
      #  { caption: 'Unrealized gains'        , balance:    100, depth: 1 },
      #  { caption: 'Retained earnings'       , balance:  5_100, depth: 1 },

      #  { caption: 'Income'                  , balance:  5_100, depth: 0 },
      #  { caption: 'Long-term capital gains' , balance:      0, depth: 1 },
      #  { caption: 'Salary'                  , balance:  5_000, depth: 1 },
      #  { caption: 'Short-term capital gains', balance:    100, depth: 1 },

      #  { caption: 'Expense', balance: 0, depth: 0 }]
      it 'should include unrealized gains'
#      it 'should include unrealized gains' do
#        presenter = AccountsPresenter.new(entity)
#        expect(presenter).to include_account_display_record(caption: 'Unrealized gains',
#                                                            balance: 100,
#                                                            depth: 1)
#      end
    end
  end
end
