require 'spec_helper'

describe Account do
  let(:attributes) do
    {
      :name => 'Cash',
      :account_type => Account.asset_type,
      :balance => 12.21
    }
  end
  
  let (:entity) { FactoryGirl.create(:entity) }
  let!(:checking) { FactoryGirl.create(:asset_account, name: 'checking', entity_id: entity.id) }
  let!(:credit_card) { FactoryGirl.create(:liability_account, name: 'credit card', entity_id: entity.id) }
  let!(:earnings) { FactoryGirl.create(:equity_account, name: 'earnings', entity_id: entity.id) }
  let!(:salary) { FactoryGirl.create(:income_account, name: 'salary', entity_id: entity.id) }
  let!(:groceries) { FactoryGirl.create(:expense_account, name: 'groceries', entity_id: entity.id) }
  let!(:opening_balances) { FactoryGirl.create(:equity_account, name: 'opening balances', entity: entity) }
  
  shared_context 'savings accounts' do
    let (:savings) { FactoryGirl.create(:asset_account, name: 'savings', entity: entity) }
    let (:car) { FactoryGirl.create(:asset_account, name: 'car', entity: entity, parent: savings) }
    let (:reserve) { FactoryGirl.create(:asset_account, name: 'reserve', entity: entity, parent: savings) }
    let!(:car_opening) { FactoryGirl.create(:transaction, amount: 1_000, debit_account: car, credit_account: opening_balances) }
    let!(:reserve_opening) { FactoryGirl.create(:transaction, amount: 24_000, debit_account: reserve, credit_account: opening_balances) }
  end

  shared_context 'investment accounts' do
    let (:ira) { FactoryGirl.create(:commodities_account, name: 'IRA', entity: entity) }
    let!(:kss) { FactoryGirl.create(:commodity, symbol: 'kss', entity: entity) }
    let (:kss_account) { Account.find_by_name('kss') }
    let!(:account_opening) { FactoryGirl.create(:transaction, transaction_date: '2014-01-01', amount: 3_000, debit_account: ira, credit_account: opening_balances) }
    let!(:purchase1) do
      CommodityTransactionCreator.new(
        account: ira,
        action: CommodityTransactionCreator.buy,
        symbol: 'kss',
        shares: 100,
        transaction_date: '2014-01-01',
        value: 1_000
      ).create!
    end
    let!(:purchase2) do
      CommodityTransactionCreator.new(
        account: ira,
        action: CommodityTransactionCreator.buy,
        symbol: 'kss',
        shares: 100,
        transaction_date: '2014-02-01',
        value: 1_200
      ).create!
    end
    let!(:price) { FactoryGirl.create(:price, commodity: kss, price: 14, trade_date: '2014-03-01') }
  end

  shared_context 'currency as of' do
    let!(:paycheck1) { FactoryGirl.create(:transaction, transaction_date: '2015-01-01',
                                          description: 'Paycheck',
                                          amount: 1_000,
                                          debit_account: checking,
                                          credit_account: salary) }
    let!(:paycheck2) { FactoryGirl.create(:transaction, transaction_date: '2015-01-15',
                                          description: 'Paycheck',
                                          amount: 1_000,
                                          debit_account: checking,
                                          credit_account: salary) }
  end

  it 'should be creatable from valid attributes' do
    account = Account.new(attributes)
    account.should be_valid
  end
  
  describe '::ACCOUNT_TYPES' do
    it 'should list the available account types' do
      Account::ACCOUNT_TYPES.should == %w(asset expense liability equity income)
    end
  end

  describe '#account_type' do
    it 'should be required' do
      account = Account.new(attributes.without(:account_type))
      account.should_not be_valid
    end
    
    it 'should be either asset, equity, or liability' do
      account = Account.new(attributes.merge({account_type: 'invalid_account_type'}))
      account.should_not be_valid
    end
  end
  
  describe '#balance' do
    it 'should default to zero' do
      account = Account.new(attributes.without(:balance))
      account.balance.should == 0
    end
  end
  
  describe '#balance_as_of' do
    let!(:t1) do
      FactoryGirl.create(:transaction,  entity: entity,
                                        transaction_date: '2013-01-02', 
                                        description: 'Paycheck', 
                                        credit_account: salary,
                                        debit_account: checking,
                                        amount: 3000
                                        )
    end
    let!(:t2) do
      FactoryGirl.create(:transaction,  entity: entity,
                                        transaction_date: '2013-01-03', 
                                        description: 'Kroger',
                                        credit_account: checking,
                                        debit_account: groceries,
                                        amount: 50
                                        )
    end
    
    it 'should calculate the balance as the the specified date' do
      checking.balance_as_of('2013-01-01').to_i.should == 0
      checking.balance_as_of('2013-01-02').to_i.should == 3000
      checking.balance_as_of('2013-01-03').to_i.should == 2950
    end
  end
  
  describe '#balance_between' do
    let!(:t1) do
      entity.transactions.create!(transaction_date: '2013-01-02', 
                                  description: 'Paycheck', 
                                  items_attributes: [
                                    {account_id: salary.id, action: 'credit', amount: 3000}, 
                                    {account_id: checking.id, action: 'debit', amount: 3000}
                                  ]
                                  )
    end
    let!(:t2) do
      entity.transactions.create!(transaction_date: '2013-01-03', 
                                  description: 'Kroger', 
                                  items_attributes: [
                                    {account_id: checking.id, action: 'credit', amount: 50}, 
                                    {account_id: groceries.id, action: 'debit', amount: 50}
                                  ]
                                  )
    end
    
    it 'should calculate the balance between the specified dates' do
      checking.balance_between('2013-01-03', '2013-01-04').should == BigDecimal.new(-50)
    end
  end
  
  shared_context 'groceries' do
    let!(:food) { FactoryGirl.create(:expense_account, name: 'Food', parent_id: groceries.id) }
    let!(:non_food) { FactoryGirl.create(:expense_account, name: 'Food', parent_id: groceries.id) }
    let!(:t1) do
      FactoryGirl.create(:transaction,
                         amount: 1_000,
                         debit_account: checking,
                         credit_account: opening_balances)
    end
    let!(:t1) do
      FactoryGirl.create(:transaction,
                         amount: 1_000,
                         debit_account: checking,
                         credit_account: opening_balances)
    end
    let!(:t2) do
      FactoryGirl.create(:transaction,
                         amount: 11,
                         debit_account: food,
                         credit_account: checking)
    end
    let!(:t3) do
      FactoryGirl.create(:transaction,
                         amount: 12,
                         debit_account: non_food,
                         credit_account: checking)
    end
  end

  describe '#balance_with_children' do
    include_context 'groceries'
    
    it 'should be the balance of the account plus the sum of the balances of the child accounts' do
      groceries.reload
      groceries.balance_with_children.should == 23
    end
  end

  describe '#children_value' do
    include_context 'groceries'

    it 'should return the sum of the #value results of the children' do
      expect(groceries.children_value).to eq(23)
    end
  end

  describe '#parent' do
    let(:parent) { FactoryGirl.create(:asset_account) }
    
    it 'should refer to another account' do
      account = Account.new(attributes.merge(parent_id: parent.id))
      account.parent.should_not be_nil
      account.parent.should == parent
    end
    
    it 'must be the same type of account' do
      account = Account.new(attributes.merge(parent_id: parent.id, account_type: Account.liability_type))
      account.should_not be_valid
    end
  end
  
  describe '#parent_name' do
    let(:parent) { FactoryGirl.create(:asset_account, name: 'Parent Account') }
    
    it 'should get the name of the parent if a parent is specified' do
      account = parent.children.new(name: 'Child')
      account.parent_name.should == 'Parent Account'
    end
    
    it 'should be nil if the parent is not specified' do
      account = Account.new(attributes)
      account.parent_name.should be_nil
    end
  end
  
  describe '#path' do
    let(:parent) { FactoryGirl.create(:asset_account, name: 'Parent Account') }
    
    it 'should get the name of account prefixed with any parent names' do
      account = parent.children.new(name: 'Child')
      account.path.should == 'Parent Account/Child'
    end
  end
  
  describe '#children' do
    let (:parent) { FactoryGirl.create(:asset_account) }
    let!(:child1) { FactoryGirl.create(:asset_account, parent_id: parent.id, name: 'Z should be second') }
    let!(:child2) { FactoryGirl.create(:asset_account, parent_id: parent.id, name: 'A should be first') }
    
    it 'should contain the child accounts in alphabetical order' do
      parent.children.should == [child2, child1]
    end
  end
  
  describe '#depth' do
    let (:parent) { FactoryGirl.create(:asset_account) }
    let!(:child1) { FactoryGirl.create(:asset_account, parent_id: parent.id) }
    
    it 'should return the number of parents in the parent-child chain' do
        parent.depth.should == 0
        child1.depth.should == 1
    end
  end

  describe '#content_type' do
    it 'should default to "currency"' do
      account = entity.accounts.new(attributes)
      account.should be_valid
      account.content_type.should == Account.currency_content
    end

    it 'should accept "currency"' do
      account = entity.accounts.new(attributes.merge(content_type: Account.currency_content))
      account.should be_valid
    end

    it 'should accept "commodity"' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodity_content))
      account.should be_valid
    end

    it 'should accept "commodities"' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodities_content))
      account.should be_valid
    end

    it 'should not accept invalid entries' do
      account = entity.accounts.new(attributes.merge(content_type: 'notvalid'))
      account.should_not be_valid
    end
  end

  describe '#currency?' do
    it 'should be true if the account type is currency' do
      account = entity.accounts.new(attributes.merge(content_type: Account.currency_content))
      account.should be_currency
    end

    it 'should be false if the account type is not currency' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodities_content))
      account.should_not be_currency
    end
  end

  describe '#commodity?' do
    it 'should be true if the account type is commodity' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodity_content))
      account.should be_commodity
    end

    it 'should be false if the account type is not commodities' do
      account = entity.accounts.new(attributes.merge(content_type: Account.currency_content))
      account.should_not be_commodity
    end
  end

  describe '#commodities?' do
    it 'should be true if the account type is commodities' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodities_content))
      account.should be_commodities
    end

    it 'should be false if the account type is not commodities' do
      account = entity.accounts.new(attributes.merge(content_type: Account.currency_content))
      account.should_not be_commodities
    end
  end

  describe 'asset scope' do
    include_context 'investment accounts'

    it 'should return a list of asset accounts' do
      Account.asset.should == [ira, checking, kss_account]
    end
  end
  
  describe 'liability scope' do
    it 'should return a list of liability accounts' do
      Account.liability.should == [credit_card]
    end
  end
  
  describe 'equity scope' do
    it 'should return a list of equity accounts' do
      Account.equity.should == [earnings, opening_balances]
    end
  end
  
  describe 'income scope' do
    it 'should return a list of income accounts' do
      Account.income.should == [salary]
    end
  end
  
  describe 'expense scope' do
    it 'should return a list of expense accounts' do
      Account.expense.should == [groceries]
    end
  end

  describe 'commodities scope' do
    include_context 'investment accounts'

    it 'should return a list of commodities accounts' do
      Account.commodities.should == [ira]
    end
  end
  
  describe '#debit' do
    it 'should increase the balance of an asset account' do
      lambda do
        checking.debit(1)
      end.should change(checking, :balance).by(1)
    end
    
    it 'should decrease the balance of a liability account' do
      lambda do
        credit_card.debit(1)
      end.should change(credit_card, :balance).by(-1)
    end
    
    it 'should decrease the balance of an equity account' do
      lambda do
        earnings.debit(1)
      end.should change(earnings, :balance).by(-1)
    end
    
    it 'should increase the balance of an expense account' do
      lambda do
        groceries.debit(1)
      end.should change(groceries, :balance).by(1)
    end
    
    it 'should decrease the balance of an income account' do
      lambda do
        salary.debit(1)
      end.should change(salary, :balance).by(-1)
    end
    
  end
  
  describe '#credit' do
    it 'should decrease the balance of an asset account' do
      lambda do
        checking.credit(1)
      end.should change(checking, :balance).by(-1)
    end
    
    it 'should increase the balance of a liability account' do
      lambda do
        credit_card.credit(1)
      end.should change(credit_card, :balance).by(1)
    end
    
    it 'should increase the balance of an equity account' do
      lambda do
        earnings.credit(1)
      end.should change(earnings, :balance).by(1)
    end
    
    it 'should decrease the balance of an expense account' do
      lambda do
        groceries.credit(1)
      end.should change(groceries, :balance).by(-1)
    end
    
    it 'should increase the balance of an income account' do
      lambda do
        salary.credit(1)
      end.should change(salary, :balance).by(1)
    end    
  end
  
  describe '#reconciliations' do
    let!(:reconciliation) { FactoryGirl.create(:reconciliation, account: checking) }
    it 'should contain a list of reconciliations for the account' do
      checking.reconciliations.should == [reconciliation]
    end
  end
  
  describe '#transaction_items' do
    let!(:t1) { FactoryGirl.create(:transaction, credit_account: checking, debit_account: groceries, amount: 100) }
    it 'should contain a list of transaction items for the account' do
      checking.transaction_items.should == t1.items.where(account_id: checking.id)
      groceries.transaction_items.should == t1.items.where(account_id: groceries)
    end
  end
  
# |               | Debit    | Credit   |
# |Asset          | Increase | Decrease |
# |Liability      | Decrease | Increase |
# |Income/Revenue | Decrease | Increase |
# |Expense        | Increase | Decrease |
# |Equity/Capital | Decrease | Increase |

  describe '#polarity' do
    context 'for a credit action' do
      let(:action) { TransactionItem.credit }
      it 'should be negative for an asset account' do
        FactoryGirl.create(:asset_account).polarity(action).should == -1
      end
      
      it 'should be positive for an liability account' do
        FactoryGirl.create(:liability_account).polarity(action).should == 1
      end
      
      it 'should be positive for an income account' do
        FactoryGirl.create(:income_account).polarity(action).should == 1
      end
      
      it 'should be negative for an expense account' do
        FactoryGirl.create(:expense_account).polarity(action).should == -1
      end
      
      it 'should be positive for an equity account' do
        FactoryGirl.create(:equity_account).polarity(action).should == 1
      end
    end
    
    context 'for a debit action' do
      let(:action) { TransactionItem.debit }
      it 'should be positive for an asset account' do
        FactoryGirl.create(:asset_account).polarity(action).should == 1
      end
      
      it 'should be negative for an liability account' do
        FactoryGirl.create(:liability_account).polarity(action).should == -1
      end
      
      it 'should be negative for an income account' do
        FactoryGirl.create(:income_account).polarity(action).should == -1
      end
      
      it 'should be positive for an expense account' do
        FactoryGirl.create(:expense_account).polarity(action).should == 1
      end
      
      it 'should be negative for an equity account' do
        FactoryGirl.create(:equity_account).polarity(action).should == -1
      end
    end
  end

  describe '#lots' do
    it 'should contain a list of commodity lots for the account' do
      account = Account.new(attributes)
      expect(account.lots).to be_empty
    end
  end

  describe '#infer_action' do
    context 'for an asset account' do
      let(:account) { FactoryGirl.create(:asset_account) }

      it 'should return credit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.credit)
      end

      it 'should return debit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.debit)
      end
    end

    context 'for an expense account' do
      let(:account) { FactoryGirl.create(:expense_account) }

      it 'should return credit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.credit)
      end

      it 'should return debit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.debit)
      end
    end

    context 'for a liability account' do
      let(:account) { FactoryGirl.create(:liability_account) }

      it 'should return debit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.debit)
      end

      it 'should return credit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.credit)
      end
    end

    context 'for an equity account' do
      let(:account) { FactoryGirl.create(:equity_account) }

      it 'should return debit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.debit)
      end

      it 'should return credit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.credit)
      end
    end

    context 'for an income account' do
      let(:account) { FactoryGirl.create(:income_account) }

      it 'should return debit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.debit)
      end

      it 'should return credit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.credit)
      end
    end
  end

  context 'for a currency account' do
    include_context 'savings accounts'

    describe '#value' do
      it 'should return the balance' do
        expect(savings.value).to eq(0)
        expect(car.value).to eq(1_000)
      end
    end

    describe '#value_as_of' do
      let!(:p1) { FactoryGirl.create(:transaction, transaction_date: Chronic.parse('2015-01-01'),
                                                   description: 'Paycheck',
                                                   entity: entity,
                                                   amount: 1000,
                                                   debit_account: checking,
                                                   credit_account: salary) }
      let!(:g1) { FactoryGirl.create(:transaction, transaction_date: Chronic.parse('2015-01-04'),
                                                   description: 'Kroger',
                                                   entity: entity,
                                                   amount: 100,
                                                   debit_account: groceries,
                                                   credit_account: checking) }
      let!(:p2) { FactoryGirl.create(:transaction, transaction_date: Chronic.parse('2015-01-15'),
                                                   description: 'Paycheck',
                                                   entity: entity,
                                                   amount: 1000,
                                                   debit_account: checking,
                                                   credit_account: salary) }
      it 'should return the balance_as_of value' do
        expect(checking.value_as_of('2015-01-02')).to eq(1000)
        expect(checking.value_as_of('2015-01-04')).to eq(900)
        expect(checking.value_as_of('2015-02-01')).to eq(1900)
      end
    end

    describe '#cost' do
      it 'should return the balance' do
        expect(car.cost).to eq(1_000)
      end
    end

    describe '#cost_as_of' do
      include_context 'currency as of'
      it 'should return the balance_as_of amount' do
        expect(checking.cost_as_of('2015-01-14')).to eq(1_000)
        expect(checking.cost_as_of('2015-01-15')).to eq(2_000)
      end
    end

    describe '#gains' do
      it 'should return zero' do
        expect(reserve.gains).to eq(0)
      end
    end

    describe '#gains_as_of' do
      include_context 'currency as of'
      it 'should return zero' do
        expect(checking.gains_as_of('2014-01-14')).to eq(0)
        expect(checking.gains_as_of('2014-01-15')).to eq(0)
      end
    end

    describe '#shares' do
      it 'should return zero' do
        expect(reserve.shares).to eq(0)
      end
    end
  end

  context 'for a commodity account' do
    include_context 'investment accounts'

    describe '#value' do
      it 'should return the current value of the shares of the commodity currently held in the account' do
        expect(kss_account.value).to eq(2_800)
      end
    end

    describe '#value_as_of' do
      let!(:price) {FactoryGirl.create(:price, commodity: kss, trade_date: '2014-03-01', price: 15)}
      it 'should return the value of the shares of the commidity based on the price that is before and closest to the specified date' do
        expect(kss_account.value_as_of('2014-01-01')).to eq(1_000) # 1,000 (1 100-share lot  at $10/share)
        expect(kss_account.value_as_of('2014-02-01')).to eq(2_400) # 2,400 (2 100-share lots at $12/share)
        expect(kss_account.value_as_of('2014-03-02')).to eq(3_000) # 3,000 (2 100-share lots at $15/share)
      end
    end

    describe '#cost' do
      it 'should return the sum of the lot costs' do
        expect(kss_account.cost).to eq(2_200)
      end
    end

    describe '#cost_as_of' do
      it 'should return what was the cost at the specified date' do
        expect(kss_account.cost_as_of('2014-01-31')).to eq(1_000)
        expect(kss_account.cost_as_of('2014-02-01')).to eq(2_200)
      end
    end

    describe '#gains' do
      it 'should return the difference between the current value and the cost of the account contents' do
        expect(kss_account.gains).to eq(600)
      end
    end

    describe '#gains_as_of' do
      let!(:kss_price1) { FactoryGirl.create(:price, commodity: kss,
                                                    trade_date: '2014-01-15',
                                                    price: 11) }
      let!(:kss_price2) { FactoryGirl.create(:price, commodity: kss,
                                                    trade_date: '2014-02-15',
                                                    price: 13) }
      it 'should return the gains at the specified date' do
        expect(kss_account.gains_as_of('2014-01-02')).to eq(0)   # 100 shares @10 valued at 1000
        expect(kss_account.gains_as_of('2014-01-15')).to eq(100) # 100 shares @10 valued at 1100
        expect(kss_account.gains_as_of('2014-02-01')).to eq(200) # 100 shares @10 + 100 shares @12 valued at 2400
        expect(kss_account.gains_as_of('2014-02-28')).to eq(400) # 100 shares @10 + 100 shares @12 valued at 2600
      end
    end

    describe '#shares' do
      it 'should return the total number of shares held in the account' do
        expect(kss_account.shares).to eq(200)
      end
    end
  end

  context 'for a commodities account' do
    include_context 'investment accounts'

    describe '#gains' do
      it 'should return the zero' do
        expect(ira.gains).to eq(0)
      end
    end

    describe '#gains_as_of' do
      it 'should return zero' do
        expect(ira.gains_as_of('2014-01-31')).to eq(0)
        expect(ira.gains_as_of('2014-02-01')).to eq(0)
      end
    end

    describe '#value' do
      it 'should return the cash balance' do
        expect(ira.value).to eq(800)
      end
    end

    describe '#value_with_children_as_of' do
      it 'should return the value of the shares of the commidity based on the price that is before and closest to the specified date' do
        expect(ira.value_with_children_as_of('2014-01-01')).to eq(3_000) # 2,000.00 in cash, 1,000 in KSS stock (1 100-share lot at $10/share)
        expect(ira.value_with_children_as_of('2014-02-01')).to eq(3_200) #   800.00 in cash, 2,400 in KSS stock (2 100-share lots at $12/share)
        expect(ira.value_with_children_as_of('2014-03-02')).to eq(3_600) #   800.00 in cash, 2,800 in KSS stock (2 100-share lots at $14/share)
      end
    end

    describe '#cost' do
      it 'should return the cash value' do
        expect(ira.cost).to eq(800)
      end
    end

    describe '#cost_as_of' do
      it 'should return the balance_as_of amount' do
        expect(ira.cost_as_of('2014-01-31')).to eq(2_000)
        expect(ira.cost_as_of('2014-02-01')).to eq(800)
      end
    end

    describe '#shares' do
      it 'should return 0' do
        expect(ira.shares).to eq(0)
      end
    end
  end

  describe '#value_with_children' do
    include_context 'investment accounts'

    it 'should return the sum of the current value and all children values' do
      ira.reload
      expect(ira.value_with_children).to eq(3_600)
    end
  end

  describe '#cost_with_children' do
    include_context 'investment accounts'

    it 'should return the sum of the cost of all children and the instance cost' do
      ira.reload
      expect(ira.cost_with_children).to eq(3_000)
    end
  end

  describe '#children_cost' do
    include_context 'investment accounts'

    it 'should return the sum of the cost of all the children' do
      ira.reload
      expect(ira.children_cost).to eq(2_200)
    end
  end

  describe '#gains_with_children' do
    include_context 'investment accounts'

    it 'should return the amount that would be earned if all holdings in this account and all child accounts were sold today' do
      ira.reload
      expect(ira.gains_with_children).to eq(600)
    end
  end

  describe '::find_by_path' do
    include_context 'savings accounts'
    let!(:spouse) { FactoryGirl.create(:asset_account, name: 'spouse', entity: entity, parent: car) }

    it 'should return the specified account' do
      spouse_car = Account.find_by_path('savings/car/spouse')
      expect(spouse_car).not_to be_nil
      expect(spouse_car).to eq(spouse)
    end
  end

  describe '#name' do
    it 'is required' do
      account = entity.accounts.new(attributes.except(:name))
      expect(account).to have(1).error_on(:name)
    end

    it 'cannot be duplicated between root accounts' do
      a1 = entity.accounts.create!(name: 'Salary', account_type: Account.income_type)
      a2 = entity.accounts.new(name: 'Salary', account_type: Account.income_type)
      expect(a2).to have(1).error_on(:name)
    end

    it 'can be the same for accounts with different parents' do
      auto = entity.accounts.create!(name: 'Auto', account_type: Account.expense_type)
      utilities = entity.accounts.create!(name: 'Utilities', account_type: Account.expense_type)
      gas1 = entity.accounts.create!(name: 'Gas', account_type: Account.expense_type, parent: auto)
      gas2 = entity.accounts.new(name: 'Gas', account_type: Account.expense_type, parent: utilities)
      expect(gas2).to be_valid
    end

    it 'cannot be duplicated between two accounts with the same parent' do
      food1 = entity.accounts.create!(name: 'Food', account_type: Account.expense_type, parent: groceries)
      food2 = entity.accounts.new(name: 'Food', account_type: Account.expense_type, parent: groceries)
      expect(food2).to have(1).error_on(:name)
    end
  end

  shared_context 'misc transactions' do
    let (:t1) do
      FactoryGirl.create(:transaction, amount: 999,
                                       transaction_date: '2015-01-01',
                                       description: 'opening balance',
                                       debit_account: checking,
                                       credit_account: opening_balances)
    end
    let (:t2) do
      FactoryGirl.create(:transaction, amount: 1_000,
                                       transaction_date: '2015-01-02',
                                       description: 'paycheck',
                                       debit_account: checking,
                                       credit_account: salary)
    end
  end

  describe '#first_transaction_item' do
    include_context 'misc transactions'

    it 'is nil for an account with no transaction items' do
      expect(checking.first_transaction_item).to be_nil
    end

    it 'is the item with the earliest date for accounts with at least one transaction item' do
      t2 # create the first transaction
      checking.reload
      expect(checking.first_transaction_item.transaction_date.to_s).to eq('2015-01-02')
    end

    it 'is updated when a new transaction is created with date that is earlier than the existing first' do
      t2 # create the first transaction
      item = t1.items.select{|i| i.account_id == checking.id}.first # create the second transaction

      expect(checking.first_transaction_item_id).to eq(item.id)
    end
  end

  describe '#head_transaction_item' do
    include_context 'misc transactions'

    it 'is nil for an account with no transaction items' do
      expect(checking.head_transaction_item).to be_nil
    end

    it 'is the item with the latest date for accounts with at least one transaction item' do
      t2 # create the first transaction item
      expect(checking.head_transaction_item.transaction_date.to_s).to eq('2015-01-02')
    end

    it 'is updated when a new transaction is created with date that is later than the existing head' do
      t1 # create the second transaction item
      item = t2.items.select{|i| i.account_id == checking.id}.first  # create the first transaction item
      expect(checking.head_transaction_item_id).to eq(item.id)
    end
  end

  describe 'creating a transaction' do
    include_context 'misc transactions'

    context 'the first time' do
      it 'updates the balance' do
        expect do
          t1
        end.to change(checking, :balance).by(999)
      end

      it 'updates the balance with children'
    end

    context 'with an appending transaction' do
      it 'updates the balance' do
        t1
        expect do
          t2
        end.to change(checking, :balance).by(1_000)
      end

      it 'updates the balance with children'
    end

    context 'with a prepending transaction' do
      it 'updates the balance' do
        t2
        expect do
          t1
          checking.reload
        end.to change(checking, :balance).by(999)
      end

      it 'updates the balance with children'
    end
  end

  describe '#transaction_items_backward' do
    let (:t1) do
      FactoryGirl.create(:transaction, entity: entity,
                                       transaction_date: Chronic.parse('2015-01-01'),
                                       description: 'Paycheck',
                                       amount: 2_000,
                                       debit_account: checking,
                                       credit_account: salary)
    end
    let (:t2) do
      FactoryGirl.create(:transaction, entity: entity,
                                       transaction_date: Chronic.parse('2015-01-04'),
                                       description: 'Market Street',
                                       amount: 100,
                                       debit_account: groceries,
                                       credit_account: checking)
    end
    let (:t3) do
      FactoryGirl.create(:transaction, entity: entity,
                                       transaction_date: Chronic.parse('2015-01-15'),
                                       description: 'Paycheck',
                                       amount: 2_000,
                                       debit_account: checking,
                                       credit_account: salary)
    end
    context 'when items are added in sequence' do
      it 'enumerates the transactions items in reverse chronological order' do
        t1
        t2
        t3
        actual = checking.transaction_items_backward.map{|i| i.transaction_date.to_s}
        expect(actual).to eq(%w(2015-01-15 2015-01-04 2015-01-01))
      end
    end

    context 'when items are added out of sequence' do
      it 'enumerates the transactions items in reverse chronological order' do
        t1
        t3
        t2
        actual = checking.transaction_items_backward.map{|i| i.transaction_date.to_s}
        expect(actual).to eq(%w(2015-01-15 2015-01-04 2015-01-01))
      end
    end
  end
end
