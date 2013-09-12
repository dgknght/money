require 'spec_helper'

describe Account do
  let(:attributes) do
    {
      :name => 'Cash',
      :account_type => :asset
    }
  end
  
  let!(:checking) { FactoryGirl.create(:asset_account, :name => 'checking') }
  let!(:credit_card) { FactoryGirl.create(:liability_account, :name => 'credit card') }
  let!(:earnings) { FactoryGirl.create(:equity_account, :name => 'earnings') }
  
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
      account = Account.new(attributes.merge({account_type: :invalid_account_type}))
      account.should_not be_valid
    end
  end
  
  context 'assets scope' do
    it 'should return a list of asset accounts' do
      Account.assets.should == [checking]
    end
  end
  
  context 'liabilities scope' do
    it 'should return a list of liability accounts' do
      Account.liabilities.should == [credit_card]
    end
  end
  
  context 'equity scope' do
    it 'should return a list of equity accounts' do
      Account.equities.should == [earnings]
    end
  end
end