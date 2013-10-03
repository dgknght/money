require 'spec_helper'

describe Account do
  let(:attributes) do
    {
      :name => 'Cash',
      :account_type => Account.asset_type,
      :balance => 12.21
    }
  end
  
  let!(:checking) { FactoryGirl.create(:asset_account, :name => 'checking') }
  let!(:credit_card) { FactoryGirl.create(:liability_account, :name => 'credit card') }
  let!(:earnings) { FactoryGirl.create(:equity_account, :name => 'earnings') }
  let!(:salary) { FactoryGirl.create(:income_account, :name => 'salary') }
  let!(:groceries) { FactoryGirl.create(:expense_account, :name => 'groceries') }
  
  it 'should be creatable from valid attributes' do
    account = Account.new(attributes)
    account.should be_valid
  end
  
  describe 'account_type' do
    it 'should be required' do
      account = Account.new(attributes.without(:account_type))
      account.should_not be_valid
    end
    
    it 'should be either asset, equity, or liability' do
      account = Account.new(attributes.merge({account_type: 'invalid_account_type'}))
      account.should_not be_valid
    end
  end
  
  describe 'balance' do
    it 'should default to zero' do
      account = Account.new(attributes.without(:balance))
      account.balance.should == 0
    end
  end
  
  describe 'balance_with_children' do
    let!(:food) { FactoryGirl.create(:expense_account, name: 'Food', parent_id: groceries.id, balance: 11) }
    let!(:non_food) { FactoryGirl.create(:expense_account, name: 'Food', parent_id: groceries.id, balance: 12) }
    
    it 'should be the balance of the account plus the sum of the balances of the child accounts' do
      groceries.balance_with_children.should == 23
    end
  end
  
  describe 'parent' do
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
  
  describe 'parent_name' do
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
  
  describe 'path' do
    let(:parent) { FactoryGirl.create(:asset_account, name: 'Parent Account') }
    
    it 'should get the name of account prefixed with any parent names' do
      account = parent.children.new(name: 'Child')
      account.path.should == 'Parent Account/Child'
    end
  end
  
  describe 'children' do
    let (:parent) { FactoryGirl.create(:asset_account) }
    let!(:child1) { FactoryGirl.create(:asset_account, parent_id: parent.id, name: 'Z should be second') }
    let!(:child2) { FactoryGirl.create(:asset_account, parent_id: parent.id, name: 'A should be first') }
    
    it 'should contain the child accounts in alphabetical order' do
      parent.children.should == [child2, child1]
    end
  end
  
  describe 'depth' do
    let (:parent) { FactoryGirl.create(:asset_account) }
    let!(:child1) { FactoryGirl.create(:asset_account, parent_id: parent.id) }
    
    it 'should return the number of parents in the parent-child chain' do
        parent.depth.should == 0
        child1.depth.should == 1
    end
  end
  
  describe 'asset scope' do
    it 'should return a list of asset accounts' do
      Account.asset.should == [checking]
    end
  end
  
  describe 'liability scope' do
    it 'should return a list of liability accounts' do
      Account.liability.should == [credit_card]
    end
  end
  
  describe 'equity scope' do
    it 'should return a list of equity accounts' do
      Account.equity.should == [earnings]
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
  
  describe 'debit' do
    it 'should increase the value of an asset account' do
      lambda do
        checking.debit(1)
      end.should change(checking, :balance).by(1)
    end
    
    it 'should decrease the value of a liability account' do
      lambda do
        credit_card.debit(1)
      end.should change(credit_card, :balance).by(-1)
    end
    
    it 'should decrease the value of an equity account' do
      lambda do
        earnings.debit(1)
      end.should change(earnings, :balance).by(-1)
    end
    
    it 'should increase the value of an expense account' do
      lambda do
        groceries.debit(1)
      end.should change(groceries, :balance).by(1)
    end
    
    it 'should decrease the value of an income account' do
      lambda do
        salary.debit(1)
      end.should change(salary, :balance).by(-1)
    end
    
  end
  
  describe 'credit' do
    it 'should decrease the value of an asset account' do
      lambda do
        checking.credit(1)
      end.should change(checking, :balance).by(-1)
    end
    
    it 'should increase the value of a liability account' do
      lambda do
        credit_card.credit(1)
      end.should change(credit_card, :balance).by(1)
    end
    
    it 'should increase the value of an equity account' do
      lambda do
        earnings.credit(1)
      end.should change(earnings, :balance).by(1)
    end
    
    it 'should decrease the value of an expense account' do
      lambda do
        groceries.credit(1)
      end.should change(groceries, :balance).by(-1)
    end
    
    it 'should increase the value of an income account' do
      lambda do
        salary.credit(1)
      end.should change(salary, :balance).by(1)
    end    
  end
end
