require 'spec_helper'

describe TransactionItem do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity, name: 'Groceries') }
  let (:gasoline) { FactoryGirl.create(:expense_account, entity: entity, name: 'Gasoline') }
  let (:transaction) { FactoryGirl.create(:transaction, entity: entity) }
  let (:salary) { FactoryGirl.create(:income_account, entity: entity, name: 'Credit card') }
  let (:credit_card) { FactoryGirl.create(:liability_account, entity: entity, name: 'Credit card') }
  let (:opening_balances) { FactoryGirl.create(:equity_account, entity: entity, name: 'Opening balances') }
  let (:attributes) do
    {
      transaction_id: transaction.id,
      account: checking,
      action: TransactionItem.credit,
      memo: "dinner party food",
      confirmation: '123F',
      amount: 100.00
    }
  end
  
  it 'is creatable from valid attributes' do
    item = TransactionItem.new(attributes)
    expect(item).to be_valid
  end
  
  describe '#transaction' do
    it 'is required' do
      item = TransactionItem.new(attributes.without(:transaction_id))
      expect(item).not_to be_valid
    end
    
    it 'refers to the transaction to which the item belongs' do
      item = TransactionItem.new(attributes)
      expect(item.transaction_id).to eq(transaction.id)
    end
  end
  
  describe '#account' do
    it 'is required' do
      item = TransactionItem.new(attributes.without(:account))
      expect(item).not_to be_valid
    end
  end
  
  describe '#action' do
    it 'is required' do
      item = TransactionItem.new(attributes.without(:action))
      expect(item).not_to be_valid
    end
    
    it 'allows only :credit or :debit' do
      item = TransactionItem.new(attributes.merge(action: TransactionItem.debit))
      expect(item).to be_valid
      
      item.action = :something_else
      expect(item).not_to be_valid
    end
  end
  
  describe '#amount' do
    it 'is required' do
      item = TransactionItem.new(attributes.without(:amount))
      expect(item).not_to be_valid
    end
  end
  
  describe '#polarized_amount' do
    context 'with a credit action' do
      let (:action) { TransactionItem.credit }
      it 'returns a negative value for an asset account' do
        item = TransactionItem.new(attributes.merge(account: checking, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end
      
      it 'returns a positive value for a liability account' do
        item = TransactionItem.new(attributes.merge(account: credit_card, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end
      
      it 'returns a positive value for an equity account' do
        item = TransactionItem.new(attributes.merge(account: opening_balances, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end
      
      it 'returns a positive value for an income account' do
        item = TransactionItem.new(attributes.merge(account: salary, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end      
      
      it 'returns a negative value for an expense account' do
        item = TransactionItem.new(attributes.merge(account: groceries, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end      
    end
    
    context 'with a debit action' do
      let (:action) { TransactionItem.debit }
      it 'returns a positive value for an asset account' do
        item = TransactionItem.new(attributes.merge(account: checking, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end
      
      it 'returns a negative value for a liability account' do
        item = TransactionItem.new(attributes.merge(account: credit_card, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end
      
      it 'returns a negative value for an equity account' do
        item = TransactionItem.new(attributes.merge(account: opening_balances, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end
      
      it 'returns a negative value for an income account' do
        item = TransactionItem.new(attributes.merge(account: salary, action: action))
        expect(item.polarized_amount.to_i).to eq(-100)
      end      
      
      it 'returns a positive value for an expense account' do
        item = TransactionItem.new(attributes.merge(account: groceries, action: action))
        expect(item.polarized_amount.to_i).to eq(100)
      end      
    end
  end
  
  describe '::credits' do
    it 'returns the transaction items with the :credit action' do
      expect(TransactionItem.credits.where(action: TransactionItem.debit)).to be_empty
    end
  end
  
  describe '::debits' do
    it 'returns the transaction items with the :debit action' do
      expect(TransactionItem.debits.where(action: TransactionItem.credit)).to be_empty
    end
  end
  
  shared_context 'buy groceries' do
    let!(:trn){FactoryGirl.create(:transaction, debit_account: groceries, credit_account: checking, amount: 100)}
  end

  describe '#reconciled?' do
    it 'defaults to false' do
      item = TransactionItem.new(attributes)
      expect(item).not_to be_reconciled
    end    
  end
  
  context 'when reconciled' do
    let (:reconciled) { FactoryGirl.create(:transaction_item, reconciled: true) }
    it 'cannot be deleted' do
      expect { reconciled.destroy }.to raise_error(Money::CannotDeleteError)
    end
  end
  
  describe '#balance' do
    it 'contains the balance of the account as a result of the inclusion if the transaction item' do
      item = TransactionItem.new
      expect(item.balance).to be_zero
    end
  end

  describe '#unreconciled scope' do
    let!(:unreconciled) { FactoryGirl.create(:transaction_item) }
    let!(:reconciled) { FactoryGirl.create(:transaction_item, reconciled: true) }
    
    it 'returns the unreconciled transaction items' do
      expect(TransactionItem.unreconciled).not_to include(reconciled)
      expect(TransactionItem.unreconciled).to include(unreconciled)
    end
  end
  
  describe '#reconciled scope' do
    let!(:unreconciled) { FactoryGirl.create(:transaction_item) }
    let!(:reconciled) { FactoryGirl.create(:transaction_item, reconciled: true) }
    
    it 'returns the reconciled transaction items' do
      expect(TransactionItem.reconciled).to include(reconciled)
      expect(TransactionItem.reconciled).not_to include(unreconciled)
    end
  end

  describe '::opposite_action' do
    it 'returns debit when give credit' do
      result = TransactionItem.opposite_action(TransactionItem.credit)
      expect(result).to eq(TransactionItem.debit)
    end

    it 'returns credit when give debit' do
      result = TransactionItem.opposite_action(TransactionItem.debit)
      expect(result).to eq(TransactionItem.credit)
    end
  end
end
