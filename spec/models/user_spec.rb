require 'spec_helper'

describe User do
  let (:user) { FactoryGirl.create(:user) }
  let!(:checking) { FactoryGirl.create(:asset_account, :user => user, :name => 'checking') }
  let!(:savings) { FactoryGirl.create(:asset_account, :user => user, :name => 'savings') }
  let!(:credit_card) { FactoryGirl.create(:liability_account, :user => user, :name => 'credit card') }
  let!(:retained_earnings) { FactoryGirl.create(:equity_account, :user => user, :name => 'retained earnings') }

  let!(:other_user) { FactoryGirl.create(:account) }
  
  let(:attributes) do
    {
      :email => 'test_user@test.com',
      :password => 'please01',
      :password_confirmation => 'please01'
    }
  end

  it 'should be creatable given valid parameters' do
    user = User.new(attributes)
    user.should_not be_nil
    user.should be_valid
  end
  
  describe 'email' do
    it 'should be required' do
      user = User.new(attributes.without(:email))
      user.should_not be_valid
    end
  end
  
  describe 'accounts' do
    it 'should list the accounts that belong to the user' do
      user.accounts.should == [checking, savings, credit_card, retained_earnings]
    end
  end
  
  describe 'transactions' do
    let!(:t1) { FactoryGirl.create(:transaction, description: 'Kroger', user: user) }
    
    it 'should list the transactions that belong to the user' do
      user.transactions.should == [t1]
    end
  end
end
