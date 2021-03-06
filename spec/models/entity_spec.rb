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
  
  let!(:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'salary') }
  let!(:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'checking') }
  let!(:savings) { FactoryGirl.create(:asset_account, entity: entity, name: 'savings') }
  let!(:credit_card) { FactoryGirl.create(:liability_account, entity: entity, name: 'credit card') }
  let!(:retained_earnings) { FactoryGirl.create(:equity_account, entity: entity, name: 'retained earnings') }
  
  it 'is creatable from valid attributes' do
    entity = Entity.new(attributes)
    expect(entity).to be_valid
  end
  
  describe 'name' do
    it 'is required' do
      entity = Entity.new(attributes.without(:name))
      expect(entity).to_not be_valid
    end
  end
  
  describe 'user_id' do
    it 'is required' do
      entity = Entity.new(attributes.without(:user_id))
      expect(entity).to_not be_valid
    end
  end
  
  describe 'accounts' do
    it 'lists the accounts that belong to the entity' do
      expect(entity.accounts.map(&:name)).to match_array [checking, credit_card, retained_earnings, salary, savings].map(&:name)
    end
  end
  
  describe 'transactions' do
    let!(:t1) { FactoryGirl.create(:transaction, description: 'Kroger', entity: entity) }
    
    it 'lists the transactions that belong to the entity' do
      expect(entity.transactions).to eq([t1])
    end
  end
  
  describe 'budgets' do
    let!(:budget) { FactoryGirl.create(:budget, entity: entity) }
    
    it 'lists the budgets that belong to the entity' do
      expect(entity.budgets).to eq([budget])
    end
  end

  describe '#current_budget' do
    let!(:b2014) { FactoryGirl.create(:budget, entity: entity, name: '2014', start_date: Date.parse('2014-01-01')) }
    let!(:b2015) { FactoryGirl.create(:budget, entity: entity, name: '2015', start_date: Date.parse('2015-01-01')) }
    let!(:b2016) { FactoryGirl.create(:budget, entity: entity, name: '2016', start_date: Date.parse('2016-01-01')) }
    it 'returns the budget applicable to the current date' do
      Timecop.freeze(Date.parse('2015-02-27')) do
        expect(entity.current_budget).to eq(b2015)
      end
    end
  end

  describe 'budget_monitors' do
    let!(:budget_monitor) { FactoryGirl.create(:budget_monitor, entity: entity) }

    it 'lists the budget monitors defined for the entity' do
      expect(entity).to have(1).budget_monitor
    end
  end

  describe '#destroy' do
    let!(:t1) { FactoryGirl.create(:transaction, entity: entity,
                                                 debit_account: checking,
                                                 credit_account: salary) }
    let!(:attachment) { FactoryGirl.create(:attachment, owning_transaction: t1) }
    let!(:budget) { FactoryGirl.create(:budget, entity: entity) }
    let!(:budget_monitor) { FactoryGirl.create(:budget_monitor, entity: entity) }
    let!(:commodity) { FactoryGirl.create(:commodity, entity: entity) }

    it 'removes all constituent accounts from the database' do
      expect{entity.destroy!}.to change(Account, :count).by(-5)
    end

    it 'removes all constituent transactions from the database' do
      expect{entity.destroy!}.to change(Transaction, :count).by(-1)
    end

    it 'removes all constituent budgets from the database' do
      expect{entity.destroy!}.to change(Budget, :count).by(-1)
    end

    it 'removes all constituent budget monitors from the database' do
      expect{entity.destroy!}.to change(BudgetMonitor, :count).by(-1)
    end

    it 'removes all constituent attachments from the database' do
      expect{entity.destroy!}.to change(AttachmentContent, :count).by(-1)
    end

    it 'removes all constituent commodities from the database' do
      expect{entity.destroy!}.to change(Commodity, :count).by(-1)
    end
  end
end
