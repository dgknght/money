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