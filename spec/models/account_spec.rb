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
    let (:ira) { FactoryGirl.create(:commodities_account, name: '401k') }
    let!(:kss) { FactoryGirl.create(:commodity, symbol: 'kss') }
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
    let!(:price) { FactoryGirl.create(:price, commodity: kss, price: 14) }
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
    let!(:food) { FactoryGirl.create(:expense_account, name: 'Food', parent_id: groceries.id, balance: 11) }
    let!(:non_food) { FactoryGirl.create(:expense_account, name: 'Food', parent_id: groceries.id, balance: 12) }
  end

  describe '#balance_with_children' do
    include_context 'groceries'
    
    it 'should be the balance of the account plus the sum of the balances of the child accounts' do
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
      Account.asset.should == [ira, checking]
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

    describe '#cost' do
      it 'should return the balance' do
        expect(car.cost).to eq(1_000)
      end
    end

    describe '#gains' do
      it 'should return zero' do
        expect(reserve.gains).to eq(0)
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

    describe '#cost' do
      include_context 'investment accounts'

      it 'should return the sum of the lot costs' do
        expect(kss_account.cost).to eq(2_200)
      end
    end

    describe '#gains' do
      it 'should return the difference between the current value and the cost of the account contents' do
        expect(kss_account.gains).to eq(600)
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

    describe '#holdings' do
      it 'should list summaries of commodities held in the account' do
        expect(kss_account).to have(1).holding
        holding = kss_account.holdings.first
        expect(holding.commodity).to eq(kss)
        expect(holding.total_shares).to eq(200)
        expect(holding.average_price).to eq(11.00)
        expect(holding).to have(2).lots
      end
    end

    describe '#all_holdings' do
      include_context 'investment accounts'

      it 'should list summaries of commodities held in the account and all child accounts' do
        expect(ira.all_holdings).to have(1).item
      end
    end

    describe '#gains' do
      it 'should return the zero' do
        expect(ira.gains).to eq(0)
      end
    end

    describe '#value' do
      include_context 'investment accounts'

      it 'should return the cash balance' do
        expect(ira.value).to eq(800)
      end
    end

    describe '#cost' do
      include_context 'investment accounts'

      it 'should return the cash value' do
        expect(ira.cost).to eq(800)
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
      expect(ira.value_with_children).to eq(3_600)
    end
  end

  describe '#cost_with_children' do
    include_context 'investment accounts'

    it 'should return the sum of the cost of all children and the instance cost' do
      expect(ira.cost_with_children).to eq(3_000)
    end
  end

  describe '#children_cost' do
    include_context 'investment accounts'

    it 'should return the sum of the cost of all the children' do
      expect(ira.children_cost).to eq(2_200)
    end
  end

  describe '#gains_with_children' do
    include_context 'investment accounts'

    it 'should return the amount that would be earned if all holdings in this account and all child accounts were sold today' do
      expect(ira.gains_with_children).to eq(600)
    end
  end
end
