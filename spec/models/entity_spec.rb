require 'spec_helper'

describe Entity do
  let(:user) { FactoryGirl.create(:user) }
  
  let(:attributes) do
    {
      name: 'My finances',
      user_id: user.id
    }
  end

  let (:entity) { FactoryGirl.create(:entity, user: user) }
  
  let!(:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'checking') }
  let!(:savings) { FactoryGirl.create(:asset_account, entity: entity, name: 'savings') }
  let!(:credit_card) { FactoryGirl.create(:liability_account, entity: entity, name: 'credit card') }
  let!(:retained_earnings) { FactoryGirl.create(:equity_account, entity: entity, name: 'retained earnings') }
  
  it 'should be creatable from valid attributes' do
    entity = Entity.new(attributes)
    entity.should be_valid
  end
  
  describe 'name' do
    it 'should be required' do
      entity = Entity.new(attributes.without(:name))
      entity.should_not be_valid
    end
  end
  
  describe 'user_id' do
    it 'should be required' do
      entity = Entity.new(attributes.without(:user_id))
      entity.should_not be_valid
    end
  end
  
  describe 'accounts' do
    it 'should list the accounts that belong to the user' do
      entity.accounts.should == [checking, savings, credit_card, retained_earnings]
    end
  end
  
  describe 'transactions' do
    let!(:t1) { FactoryGirl.create(:transaction, description: 'Kroger', entity: entity) }
    
    it 'should list the transactions that belong to the user' do
      entity.transactions.should == [t1]
    end
  end
end
