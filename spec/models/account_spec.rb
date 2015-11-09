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
  end

  shared_context 'savings transactions' do
    let!(:car_opening) do
      TransactionManager.create_simple(entity, transaction_date: Chronic.parse('2015-01-01'),
                                               description: 'Opening balance',
                                               amount: 1_000,
                                               debit_account: car,
                                               credit_account: opening_balances)
    end
    let!(:reserve_opening) do
      TransactionManager.create_simple(entity, transaction_date: Chronic.parse('2015-01-01'),
                                               description: 'Opening balance',
                                               amount: 24_000,
                                               debit_account: reserve,
                                               credit_account: opening_balances)
    end
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
    let!(:paycheck1) { TransactionManager.create_simple(entity, transaction_date: '2015-01-01',
                                                                description: 'Paycheck',
                                                                amount: 1_000,
                                                                debit_account: checking,
                                                                credit_account: salary) }
    let!(:paycheck2) { TransactionManager.create_simple(entity, transaction_date: '2015-01-15',
                                                                description: 'Paycheck',
                                                                amount: 1_000,
                                                                debit_account: checking,
                                                                credit_account: salary) }
  end

  it 'is creatable from valid attributes' do
    account = Account.new(attributes)
    expect(account).to be_valid
  end
  
  describe '::ACCOUNT_TYPES' do
    it 'lists the available account types' do
      expect(Account::ACCOUNT_TYPES).to eq(%w(asset expense liability equity income))
    end
  end

  describe '#account_type' do
    it 'is required' do
      account = Account.new(attributes.without(:account_type))
      expect(account).not_to be_valid
    end
    
    it 'is either asset, equity, or liability' do
      account = Account.new(attributes.merge({account_type: 'invalid_account_type'}))
      expect(account).not_to be_valid
    end
  end
  
  describe '#balance' do
    it 'defaults to zero' do
      account = Account.new(attributes.without(:balance))
      expect(account.balance).to eq(0)
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
    
    it 'calculates the balance as the the specified date' do
      expect(checking.balance_as_of('2013-01-01').to_i).to eq(0)
      expect(checking.balance_as_of('2013-01-02').to_i).to eq(3000)
      expect(checking.balance_as_of('2013-01-03').to_i).to eq(2950)
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
    
    it 'calculates the balance between the specified dates' do
      expect(checking.balance_between('2013-01-03', '2013-01-04')).to eq(BigDecimal.new(-50))
    end
  end
  
  shared_context 'groceries' do
    let!(:food) { FactoryGirl.create(:expense_account, name: 'Food', parent_id: groceries.id) }
    let!(:non_food) { FactoryGirl.create(:expense_account, name: 'Food', parent_id: groceries.id) }
    let!(:t1) do
      TransactionManager.create_simple(entity, transaction_date: Date.parse('2015-01-01'),
                                               description: 'Opening balance',
                                               amount: 1_000,
                                               debit_account: checking,
                                               credit_account: opening_balances)
    end
    let!(:t2) do
      TransactionManager.create(entity, transaction_date: Date.parse('2015-01-02'),
                                        description: 'Kroger',
                                        items_attributes: [{action: TransactionItem.credit,
                                                            account: checking,
                                                            amount: 23},
                                                           {action: TransactionItem.debit,
                                                            account: food,
                                                            amount: 11},
                                                           {action: TransactionItem.debit,
                                                            account: non_food,
                                                            amount: 12}])
    end
  end

  describe '#children_balance' do
    include_context 'groceries'

    it 'is the sum of the balance_with_children values of the children' do
      groceries.reload
      expect(groceries.children_balance).to eq(23)
    end
  end

  describe '#balance_with_children' do
    include_context 'groceries'
    
    it 'is the balance of the account plus the sum of the balances of the child accounts' do
      groceries.reload
      expect(groceries.balance_with_children).to eq(23)
    end
  end

  describe '#children_value' do
    include_context 'groceries'

    it 'returns the sum of the #value results of the children' do
      groceries.reload
      expect(groceries.children_value).to eq(23)
    end
  end

  describe '#parent' do
    let(:parent) { FactoryGirl.create(:asset_account) }
    
    it 'refers to another account' do
      account = Account.new(attributes.merge(parent_id: parent.id))
      expect(account.parent).not_to be_nil
      expect(account.parent).to eq(parent)
    end
    
    it 'must be the same type of account' do
      account = Account.new(attributes.merge(parent_id: parent.id, account_type: Account.liability_type))
      expect(account).not_to be_valid
    end
  end
  
  describe '#parent_name' do
    let(:parent) { FactoryGirl.create(:asset_account, name: 'Parent Account') }
    
    it 'gets the name of the parent if a parent is specified' do
      account = parent.children.new(name: 'Child')
      expect(account.parent_name).to eq('Parent Account')
    end
    
    it 'is nil if the parent is not specified' do
      account = Account.new(attributes)
      expect(account.parent_name).to be_nil
    end
  end
  
  describe '#path' do
    let(:parent) { FactoryGirl.create(:asset_account, name: 'Parent Account') }
    
    it 'gets the name of account prefixed with any parent names' do
      account = parent.children.new(name: 'Child')
      expect(account.path).to eq('Parent Account/Child')
    end
  end

  describe '#parents' do
    let (:p1) { FactoryGirl.create(:asset_account, name: 'P1') }
    let (:p2) { FactoryGirl.create(:asset_account, name: 'P2', parent: p1) }
    let!(:c) { FactoryGirl.create(:asset_account, name: 'C', parent: p2) }

    it 'returns all of the parents in the chain for the account' do
      expect(['P2', 'P1']).to eq(c.parents.map(&:name))
    end
  end
  
  describe '#children' do
    let (:parent) { FactoryGirl.create(:asset_account) }
    let!(:child1) { FactoryGirl.create(:asset_account, parent_id: parent.id, name: 'Z is second') }
    let!(:child2) { FactoryGirl.create(:asset_account, parent_id: parent.id, name: 'A is first') }
    
    it 'contains the child accounts in alphabetical order' do
      expect(parent.children).to eq([child2, child1])
    end
  end
  
  describe '#depth' do
    let (:parent) { FactoryGirl.create(:asset_account) }
    let!(:child1) { FactoryGirl.create(:asset_account, parent_id: parent.id) }
    
    it 'returns the number of parents in the parent-child chain' do
        expect(parent.depth).to eq(0)
        expect(child1.depth).to eq(1)
    end
  end

  describe '#content_type' do
    it 'defaults to "currency"' do
      account = entity.accounts.new(attributes)
      expect(account).to be_valid
      expect(account.content_type).to eq(Account.currency_content)
    end

    it 'accepts "currency"' do
      account = entity.accounts.new(attributes.merge(content_type: Account.currency_content))
      expect(account).to be_valid
    end

    it 'accepts "commodity"' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodity_content))
      expect(account).to be_valid
    end

    it 'accepts "commodities"' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodities_content))
      expect(account).to be_valid
    end

    it 'does not accept invalid entries' do
      account = entity.accounts.new(attributes.merge(content_type: 'notvalid'))
      expect(account).not_to be_valid
    end
  end

  describe '#currency?' do
    it 'is true if the account type is currency' do
      account = entity.accounts.new(attributes.merge(content_type: Account.currency_content))
      expect(account).to be_currency
    end

    it 'is false if the account type is not currency' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodities_content))
      expect(account).not_to be_currency
    end
  end

  describe '#commodity?' do
    it 'is true if the account type is commodity' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodity_content))
      expect(account).to be_commodity
    end

    it 'is false if the account type is not commodities' do
      account = entity.accounts.new(attributes.merge(content_type: Account.currency_content))
      expect(account).not_to be_commodity
    end
  end

  describe '#commodities?' do
    it 'is true if the account type is commodities' do
      account = entity.accounts.new(attributes.merge(content_type: Account.commodities_content))
      expect(account).to be_commodities
    end

    it 'is false if the account type is not commodities' do
      account = entity.accounts.new(attributes.merge(content_type: Account.currency_content))
      expect(account).not_to be_commodities
    end
  end

  describe 'asset scope' do
    include_context 'investment accounts'

    it 'returns a list of asset accounts' do
      expect(Account.asset).to match_array([ira, checking, kss_account])
    end
  end
  
  describe 'liability scope' do
    it 'returns a list of liability accounts' do
      expect(Account.liability).to match_array([credit_card])
    end
  end
  
  describe 'equity scope' do
    it 'returns a list of equity accounts' do
      expect(Account.equity).to match_array([earnings, opening_balances])
    end
  end
  
  describe 'income scope' do
    it 'returns a list of income accounts' do
      expect(Account.income).to match_array([salary])
    end
  end
  
  describe 'expense scope' do
    it 'returns a list of expense accounts' do
      expect(Account.expense).to match_array([groceries])
    end
  end

  describe 'commodities scope' do
    include_context 'investment accounts'

    it 'returns a list of commodities accounts' do
      expect(Account.commodities).to match_array([ira])
    end
  end
  
  describe '#debit' do
    it 'increases the balance of an asset account' do
      expect do
        checking.debit(1)
      end.to change(checking, :balance).by(1)
    end
    
    it 'decreases the balance of a liability account' do
      expect do
        credit_card.debit(1)
      end.to change(credit_card, :balance).by(-1)
    end
    
    it 'decreases the balance of an equity account' do
      expect do
        earnings.debit(1)
      end.to change(earnings, :balance).by(-1)
    end
    
    it 'increases the balance of an expense account' do
      expect do
        groceries.debit(1)
      end.to change(groceries, :balance).by(1)
    end
    
    it 'decreases the balance of an income account' do
      expect do
        salary.debit(1)
      end.to change(salary, :balance).by(-1)
    end
    
  end
  
  describe '#credit' do
    it 'decreases the balance of an asset account' do
      expect do
        checking.credit(1)
      end.to change(checking, :balance).by(-1)
    end
    
    it 'increases the balance of a liability account' do
      expect do
        credit_card.credit(1)
      end.to change(credit_card, :balance).by(1)
    end
    
    it 'increases the balance of an equity account' do
      expect do
        earnings.credit(1)
      end.to change(earnings, :balance).by(1)
    end
    
    it 'decreases the balance of an expense account' do
      expect do
        groceries.credit(1)
      end.to change(groceries, :balance).by(-1)
    end
    
    it 'increases the balance of an income account' do
      expect do
        salary.credit(1)
      end.to change(salary, :balance).by(1)
    end    
  end
  
  describe '#reconciliations' do
    let!(:reconciliation) { FactoryGirl.create(:reconciliation, account: checking) }
    it 'contains a list of reconciliations for the account' do
      expect(checking.reconciliations).to eq([reconciliation])
    end
  end
  
  describe '#transaction_items' do
    let!(:t1) { FactoryGirl.create(:transaction, credit_account: checking, debit_account: groceries, amount: 100) }
    it 'contains a list of transaction items for the account' do
      expect(checking.transaction_items).to eq(t1.items.where(account_id: checking.id))
      expect(groceries.transaction_items).to eq(t1.items.where(account_id: groceries))
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
      it 'is negative for an asset account' do
        expect(FactoryGirl.create(:asset_account).polarity(action)).to eq(-1)
      end
      
      it 'is positive for an liability account' do
        expect(FactoryGirl.create(:liability_account).polarity(action)).to eq(1)
      end
      
      it 'is positive for an income account' do
        expect(FactoryGirl.create(:income_account).polarity(action)).to eq(1)
      end
      
      it 'is negative for an expense account' do
        expect(FactoryGirl.create(:expense_account).polarity(action)).to eq(-1)
      end
      
      it 'is positive for an equity account' do
        expect(FactoryGirl.create(:equity_account).polarity(action)).to eq(1)
      end
    end
    
    context 'for a debit action' do
      let(:action) { TransactionItem.debit }
      it 'is positive for an asset account' do
        expect(FactoryGirl.create(:asset_account).polarity(action)).to eq(1)
      end
      
      it 'is negative for an liability account' do
        expect(FactoryGirl.create(:liability_account).polarity(action)).to eq(-1)
      end
      
      it 'is negative for an income account' do
        expect(FactoryGirl.create(:income_account).polarity(action)).to eq(-1)
      end
      
      it 'is positive for an expense account' do
        expect(FactoryGirl.create(:expense_account).polarity(action)).to eq(1)
      end
      
      it 'is negative for an equity account' do
        expect(FactoryGirl.create(:equity_account).polarity(action)).to eq(-1)
      end
    end
  end

  describe '#lots' do
    it 'contains a list of commodity lots for the account' do
      account = Account.new(attributes)
      expect(account.lots).to be_empty
    end
  end

  describe '#infer_action' do
    context 'for an asset account' do
      let(:account) { FactoryGirl.create(:asset_account) }

      it 'returns credit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.credit)
      end

      it 'returns debit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.debit)
      end
    end

    context 'for an expense account' do
      let(:account) { FactoryGirl.create(:expense_account) }

      it 'returns credit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.credit)
      end

      it 'returns debit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.debit)
      end
    end

    context 'for a liability account' do
      let(:account) { FactoryGirl.create(:liability_account) }

      it 'returns debit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.debit)
      end

      it 'returns credit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.credit)
      end
    end

    context 'for an equity account' do
      let(:account) { FactoryGirl.create(:equity_account) }

      it 'returns debit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.debit)
      end

      it 'returns credit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.credit)
      end
    end

    context 'for an income account' do
      let(:account) { FactoryGirl.create(:income_account) }

      it 'returns debit for a negative amount' do
        action = account.infer_action(-1)
        expect(action).to eq(TransactionItem.debit)
      end

      it 'returns credit for a positive amount' do
        action = account.infer_action(1)
        expect(action).to eq(TransactionItem.credit)
      end
    end
  end

  context 'for a currency account' do
    include_context 'savings accounts'

    describe '#value' do
      include_context 'savings transactions'

      it 'returns the balance' do
        expect(savings.value).to eq(0)
        expect(car.value).to eq(1_000)
      end
    end

    describe '#value_as_of' do
      let!(:p1) { TransactionManager.create_simple(entity, transaction_date: Chronic.parse('2015-01-01'),
                                                           description: 'Paycheck',
                                                           entity: entity,
                                                           amount: 1000,
                                                           debit_account: checking,
                                                           credit_account: salary) }
      let!(:g1) { TransactionManager.create_simple(entity, transaction_date: Chronic.parse('2015-01-04'),
                                                           description: 'Kroger',
                                                           entity: entity,
                                                           amount: 100,
                                                           debit_account: groceries,
                                                           credit_account: checking) }
      let!(:p2) { TransactionManager.create_simple(entity, transaction_date: Chronic.parse('2015-01-15'),
                                                           description: 'Paycheck',
                                                           entity: entity,
                                                           amount: 1000,
                                                           debit_account: checking,
                                                           credit_account: salary) }
      it 'returns the balance_as_of value' do
        expect(checking.value_as_of('2015-01-02')).to eq(1000)
        expect(checking.value_as_of('2015-01-04')).to eq(900)
        expect(checking.value_as_of('2015-02-01')).to eq(1900)
      end
    end

    describe '#cost' do
      include_context 'savings transactions'

      it 'returns the balance' do
        expect(car.cost).to eq(1_000)
      end
    end

    describe '#cost_as_of' do
      include_context 'currency as of'
      it 'returns the balance_as_of amount' do
        expect(checking.cost_as_of('2015-01-14')).to eq(1_000)
        expect(checking.cost_as_of('2015-01-15')).to eq(2_000)
      end
    end

    describe '#gains' do
      it 'returns zero' do
        expect(reserve.gains).to eq(0)
      end
    end

    describe '#gains_as_of' do
      include_context 'currency as of'
      it 'returns zero' do
        expect(checking.gains_as_of('2014-01-14')).to eq(0)
        expect(checking.gains_as_of('2014-01-15')).to eq(0)
      end
    end

    describe '#shares' do
      it 'returns zero' do
        expect(reserve.shares).to eq(0)
      end
    end
  end

  context 'for a commodity account' do
    include_context 'investment accounts'

    describe '#value' do
      it 'returns the current value of the shares of the commodity currently held in the account' do
        expect(kss_account.value).to eq(2_800)
      end
    end

    describe '#value_as_of' do
      let!(:price) {FactoryGirl.create(:price, commodity: kss, trade_date: '2014-03-01', price: 15)}
      it 'returns the value of the shares of the commidity based on the price that is before and closest to the specified date' do
        expect(kss_account.value_as_of('2014-01-01')).to eq(1_000) # 1,000 (1 100-share lot  at $10/share)
        expect(kss_account.value_as_of('2014-02-01')).to eq(2_400) # 2,400 (2 100-share lots at $12/share)
        expect(kss_account.value_as_of('2014-03-02')).to eq(3_000) # 3,000 (2 100-share lots at $15/share)
      end
    end

    describe '#cost' do
      it 'returns the sum of the lot costs' do
        expect(kss_account.cost).to eq(2_200)
      end
    end

    describe '#cost_as_of' do
      it 'returns what was the cost at the specified date' do
        expect(kss_account.cost_as_of('2014-01-31')).to eq(1_000)
        expect(kss_account.cost_as_of('2014-02-01')).to eq(2_200)
      end
    end

    describe '#gains' do
      it 'returns the difference between the current value and the cost of the account contents' do
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
      it 'returns the gains at the specified date' do
        expect(kss_account.gains_as_of('2014-01-02')).to eq(0)   # 100 shares @10 valued at 1000
        expect(kss_account.gains_as_of('2014-01-15')).to eq(100) # 100 shares @10 valued at 1100
        expect(kss_account.gains_as_of('2014-02-01')).to eq(200) # 100 shares @10 + 100 shares @12 valued at 2400
        expect(kss_account.gains_as_of('2014-02-28')).to eq(400) # 100 shares @10 + 100 shares @12 valued at 2600
      end
    end

    describe '#shares' do
      it 'returns the total number of shares held in the account' do
        expect(kss_account.shares).to eq(200)
      end
    end

    describe '#recalculate_value!' do
      before(:each) do
        Account.connection.execute('update accounts set value = 0')
      end
      it 'sets the value attribute for the account' do
        kss_account.reload
        expect do
          kss_account.recalculate_value!
        end.to change(kss_account, :value).from(0).to(2_800)
      end
    end
  end

  context 'for a commodities account' do
    include_context 'investment accounts'

    describe '#gains' do
      it 'returns the zero' do
        expect(ira.gains).to eq(0)
      end
    end

    describe '#gains_as_of' do
      it 'returns zero' do
        expect(ira.gains_as_of('2014-01-31')).to eq(0)
        expect(ira.gains_as_of('2014-02-01')).to eq(0)
      end
    end

    describe '#value' do
      it 'returns the cash balance' do
        expect(ira.value).to eq(800)
      end
    end

    describe '#value_with_children_as_of' do
      it 'returns the value of the shares of the commidity based on the price that is before and closest to the specified date' do
        expect(ira.value_with_children_as_of('2014-01-01')).to eq(3_000) # 2,000.00 in cash, 1,000 in KSS stock (1 100-share lot at $10/share)
        expect(ira.value_with_children_as_of('2014-02-01')).to eq(3_200) #   800.00 in cash, 2,400 in KSS stock (2 100-share lots at $12/share)
        expect(ira.value_with_children_as_of('2014-03-02')).to eq(3_600) #   800.00 in cash, 2,800 in KSS stock (2 100-share lots at $14/share)
      end
    end

    describe '#cost' do
      it 'returns the cash value' do
        expect(ira.cost).to eq(800)
      end
    end

    describe '#cost_as_of' do
      it 'returns the balance_as_of amount' do
        expect(ira.cost_as_of('2014-01-31')).to eq(2_000)
        expect(ira.cost_as_of('2014-02-01')).to eq(800)
      end
    end

    describe '#shares' do
      it 'returns 0' do
        expect(ira.shares).to eq(0)
      end
    end
  end

  describe '#value_with_children' do
    include_context 'investment accounts'

    it 'returns the sum of the current value and all children values' do
      ira.reload
      expect(ira.value_with_children).to eq(3_600)
    end
  end

  describe '#cost_with_children' do
    include_context 'investment accounts'

    it 'returns the sum of the cost of all children and the instance cost' do
      ira.reload
      expect(ira.cost_with_children).to eq(3_000)
    end
  end

  describe '#children_cost' do
    include_context 'investment accounts'

    it 'returns the sum of the cost of all the children' do
      ira.reload
      expect(ira.children_cost).to eq(2_200)
    end
  end

  describe '#gains_with_children' do
    include_context 'investment accounts'

    it 'returns the amount that would be earned if all holdings in this account and all child accounts were sold today' do
      ira.reload
      expect(ira.gains_with_children).to eq(600)
    end
  end

  describe '::find_by_path' do
    include_context 'savings accounts'
    let!(:spouse) { FactoryGirl.create(:asset_account, name: 'spouse', entity: entity, parent: car) }

    it 'returns the specified account' do
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

  describe '#recalculate_balance!' do
    # Not using transaction manager on purpose here to test the balance calculations
    let!(:t1) do
      FactoryGirl.create(:transaction, entity: entity,
                                       transaction_date: Chronic.parse('2015-01-01'),
                                       description: 'Paycheck',
                                       amount: 1_000,
                                       debit_account: checking,
                                       credit_account: salary)
    end
    let!(:t2) do
      FactoryGirl.create(:transaction, entity: entity,
                                       transaction_date: Chronic.parse('2015-01-04'),
                                       description: 'Kroger',
                                       amount: 100,
                                       debit_account: groceries,
                                       credit_account: checking)
    end
    let!(:t3) do
      FactoryGirl.create(:transaction, entity: entity,
                                       transaction_date: Chronic.parse('2015-01-11'),
                                       description: 'Kroger',
                                       amount: 100,
                                       debit_account: groceries,
                                       credit_account: checking)
    end
    let!(:t4) do
      FactoryGirl.create(:transaction, entity: entity,
                                       transaction_date: Chronic.parse('2015-01-15'),
                                       description: 'Paycheck',
                                       amount: 1_000,
                                       debit_account: checking,
                                       credit_account: salary)
    end

    context 'with option rebuild_item_indexes=true' do
      it 'sets the balance attribute to the correct value' do
        expect do
          checking.recalculate_balance!(rebuild_item_indexes: true)
        end.to change(checking, :balance).from(0).to(1_800)
      end
    end
  end

  describe '#recalculate_children_balance!' do
    include_context 'savings accounts'
    include_context 'savings transactions'
    before(:each) do
      Account.connection.execute('update accounts set children_balance = 0')
    end

    it 'updates the value of the children_balance attribute' do
      savings.reload
      expect do
        savings.recalculate_children_balance!
      end.to change(savings, :children_balance).from(0).to(25_000)
    end
  end
end
