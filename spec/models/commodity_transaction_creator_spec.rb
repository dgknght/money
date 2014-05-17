require 'spec_helper'

describe CommodityTransactionCreator do
  let!(:kss) { FactoryGirl.create(:commodity, symbol: 'KSS', name: 'Knight Software Services') }
  let (:opening) { FactoryGirl.create(:equity_account, name: 'Opening balances') }
  let (:ira) { FactoryGirl.create(:account, name: 'IRA') }
  let (:attributes) do
    {
      account_id: ira.id,
      transaction_date: '2014-04-15',
      symbol: 'KSS',
      action: 'buy',
      shares: 100,
      value: 1_234.00
    }
  end

  it 'should be creatable with an account and valid attributes' do
    creator = CommodityTransactionCreator.new(attributes)
    expect(creator).to be_valid
    expect(creator.transaction_date).to eq(Date.parse('2014-04-15'))
    expect(creator.symbol).to eq('KSS')
    expect(creator.shares).to eq(100)
    expect(creator.value).to eq(1_234)
  end

  describe '#account_id' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:account_id))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:account_id)
    end
  end

  describe '#transaction_date' do
    it 'should default to the current date' do
      Timecop.freeze(Time.local(2014, 1, 1, 0, 0, 0)) do
        creator = CommodityTransactionCreator.new(attributes.except(:transaction_date))
        expect(creator).to be_valid
        expect(creator.transaction_date).to eq(Date.parse('2014-01-01'))
      end
    end
  end

  describe '#symbol' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:symbol))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:symbol)
    end
  end

  describe '#action' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:action))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:action)
    end

    it 'should accept "buy"' do
      creator = CommodityTransactionCreator.new(attributes.merge(:action => 'buy'))
      expect(creator).to be_valid
    end

    it 'should accept "sell"' do
      creator = CommodityTransactionCreator.new(attributes.merge(:action => 'sell'))
      expect(creator).to be_valid
    end

    it 'should not accept anything else' do
      creator = CommodityTransactionCreator.new(attributes.merge(action: 'notvalid'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:action)
    end
  end

  describe '#shares' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:shares))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:shares)
    end

    it 'should be a number' do
      creator = CommodityTransactionCreator.new(attributes.merge(shares: 'notanumber'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:shares)
    end
  end

  describe '#price' do
    it 'should be calculated based on the value and shares' do
      creator = CommodityTransactionCreator.new(attributes)
      expect(creator.price).to eq(12.34)
    end
  end

  describe '#value' do
    it 'should be required' do
      creator = CommodityTransactionCreator.new(attributes.except(:value))
      expect(creator).not_to be_valid
      expect(creator).to have(2).errors_on(:value)
    end

    it 'should be a number' do
      creator = CommodityTransactionCreator.new(attributes.merge(value: 'notanumber'))
      expect(creator).not_to be_valid
      expect(creator).to have(1).error_on(:value)
    end
  end

  describe '#create' do
    context 'with a "buy" action' do
      it 'should create a new transaction' do
        transaction = nil
        expect do
          creator = CommodityTransactionCreator.new(attributes)
          transaction = creator.create
        end.to change(Transaction, :count).by(1)

        expect(transaction).not_to be_nil
        expect(transaction.total_debits.to_i).to eq(1_234)
      end

      it 'should create an account to track money used to purchase this commodity, if the account does not exist' do
        CommodityTransactionCreator.new(attributes).create
        expect(Account.find_by_name('KSS')).not_to be_nil
      end

      it 'should debit the account dedicated to tracking purchases of this commodity' do
        CommodityTransactionCreator.new(attributes).create
        new_account = Account.find_by_name('KSS')
        expect(new_account.balance).to eq(1_234)
      end

      it 'should credit the account from which frunds for taken to make the purchase' do
        expect do
          CommodityTransactionCreator.new(attributes).create
          ira.reload
        end.to change(ira, :balance).by(-1_234)
      end

      it 'should create a new lot transaction' do
        expect do
          CommodityTransactionCreator.new(attributes).create
        end.to change(LotTransaction, :count).by(1)
      end

      it 'should create a new lot' do
        transaction = nil
        expect do
          CommodityTransactionCreator.new(attributes).create
        end.to change(Lot, :count).by(1)
      end
    end

    context 'with a "sell" action' do
      let!(:st_gains) do
        FactoryGirl.create(:income_account, name: 'Short-term capital gains',
                                            entity: ira.entity)
      end
      let!(:lt_gains) do
        FactoryGirl.create(:income_account, name: 'Long-term capital gains',
                                            entity: ira.entity)
      end
      context 'that sells all shares owned' do
        let (:sell_attributes) { attributes.merge(action: 'sell') }
        let!(:lot1) do
          FactoryGirl.create(:lot, account: ira,
                                   commodity: kss,
                                   price: 8.00,
                                   shares_owned: 100,
                                   purchase_date: '2014-01-01')
        end
        let!(:lot2) do
          FactoryGirl.create(:lot, account: ira,
                                   commodity: kss,
                                   price: 10.00,
                                   shares_owned: 100,
                                   purchase_date: '2014-01-02')
        end
        let!(:kss_account) do
          FactoryGirl.create(:asset_account, name: 'KSS',
                                             entity: ira.entity,
                                             parent: ira)
        end
        let!(:commodity_transaction) do
          FactoryGirl.create(:transaction, debit_account: kss_account, 
                                           credit_account: ira, 
                                           amount: 1_000)
        end

        context 'using FILO' do
          it 'should subtract the shares sold from the lot' do
            expect do
              CommodityTransactionCreator.new(sell_attributes).create
              lot2.reload
            end.to change(lot2, :shares_owned).by(-100)
          end

          context 'for commodities held one year or less' do
            it 'should debit the short-term capital gains account if the sale amount was greater than the cost of the sold commodities' do
              expect do
                CommodityTransactionCreator.new(sell_attributes).create
                st_gains.reload
              end.to change(st_gains, :balance).by(234)
            end

            it 'should credit the short-term capital gains account if the sale amount was less than the cost of the cold commodities' do
              expect do
                CommodityTransactionCreator.new(sell_attributes.merge(value: 900)).create
                st_gains.reload
              end.to change(st_gains, :balance).by(-100)
            end
          end

          context 'for commodities held longer than one year' do
            it 'should debit the long-term capital gains account if the sale amount was greater than the cost of the sold commodities' do
              expect do
                CommodityTransactionCreator.new(sell_attributes.merge(transaction_date: '2015-04-15')).create
                lt_gains.reload
              end.to change(lt_gains, :balance).by(234)
            end

            it 'should credit the long-term capital gains account if the sale amount was less than the cost of the cold commodities' do
              expect do
                CommodityTransactionCreator.new(sell_attributes.merge(transaction_date: '2015-04-15', value: 900)).create
                lt_gains.reload
              end.to change(lt_gains, :balance).by(-100)
            end
          end
        end

        context 'using FIFO' do
          let (:fifo_sell_attributes) { sell_attributes.merge(valuation_method: CommodityTransactionCreator.fifo) }

          it 'should subtract the shares sold from the lot' do
            expect do
              CommodityTransactionCreator.new(fifo_sell_attributes).create
              lot1.reload
            end.to change(lot1, :shares_owned).by(-100)
          end

          context 'for commodities held one year or less' do
            it 'should debit the short-term capital gains account if the sale amount was greater than the cost of the sold commodities' do
              expect do
                CommodityTransactionCreator.new(fifo_sell_attributes).create
                st_gains.reload
              end.to change(st_gains, :balance).by(434)
            end

            it 'should credit the short-term capital gains account if the sale amount was less than the cost of the cold commodities' do
              expect do
                CommodityTransactionCreator.new(fifo_sell_attributes.merge(value: 700)).create
                st_gains.reload
              end.to change(st_gains, :balance).by(-100)
            end
          end

          context 'for commodities held longer than one year' do
            it 'should debit the long-term capital gains account if the sale amount was greater than the cost of the sold commodities' do
              expect do
                CommodityTransactionCreator.new(fifo_sell_attributes.merge(transaction_date: '2015-04-15')).create
                lt_gains.reload
              end.to change(lt_gains, :balance).by(434)
            end

            it 'should credit the long-term capital gains account if the sale amount was less than the cost of the cold commodities' do
              expect do
                CommodityTransactionCreator.new(fifo_sell_attributes.merge(transaction_date: '2015-04-15', value: 700)).create
                lt_gains.reload
              end.to change(lt_gains, :balance).by(-100)
            end
          end
        end

        it 'should create a new transaction' do
          expect do
            CommodityTransactionCreator.new(sell_attributes).create
          end.to change(Transaction, :count).by(1)
        end

        it 'should credit the account dedicated to tracking purchases of this commodity' do
          expect do
            CommodityTransactionCreator.new(sell_attributes).create
            kss_account.reload
          end.to change(kss_account, :balance).by(-1_000)
        end

        it 'should debit the specified account' do
          expect do
            CommodityTransactionCreator.new(sell_attributes).create
            ira.reload
          end.to change(ira, :balance).by(1_234)
        end

        it 'should create a new lot transaction record' do
          expect do
            CommodityTransactionCreator.new(sell_attributes).create
          end.to change(LotTransaction, :count).by(1)
          lot_transaction = LotTransaction.last
          expect(lot_transaction.shares_traded).to eq(-100)
          expect(lot_transaction.price).to eq(12.34)
        end
      end

      context 'that sells some of the shares owned' do
        context 'using FIFO' do
          it 'should subtract shares from the first purchased, non-empty lot'
        end

        context 'using FILO' do
          it 'should subtract shares from the last purchased, non-empty lot'
        end
      end

      context 'that sells shares across multiple lots' do
        it 'should debit the gains account the correct amount'
      end

      context 'that sells shares across lots with mixed long-term and short-term gains' do
        it 'should debit the long-term gains account the correct amount'
        it 'should debit the short-term gains account the correct amount'
      end
    end
  end
end
