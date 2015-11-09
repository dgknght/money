require 'spec_helper'

describe TransactionItemCreator do
  let (:entity) { FactoryGirl.create(:entity) }
  let (:checking) { FactoryGirl.create(:asset_account, entity: entity, name: 'Checking') }
  let (:groceries) { FactoryGirl.create(:expense_account, entity: entity, name: 'Groceries') }
  let (:transaction) { FactoryGirl.create(:transaction, transaction_date: '2013-02-27', description: 'Kroger', debit_account: groceries, credit_account: checking, amount: 25) }
  let (:transaction_item) { transaction.items.select{ |i| i.account_id == checking.id }.first }
  let (:attributes) do
    {
      transaction_date: '2013-01-01',
      description: 'Market Street',
      other_account_id: groceries.id,
      amount: -100
    }
  end
  
  it 'should be creatable with an account' do
    creator = TransactionItemCreator.new(checking)
    expect(creator).not_to be_nil
  end
  
  it 'should be creatable with an account and valid attributes' do
    creator = TransactionItemCreator.new(checking, attributes)
    expect(creator).to be_valid
  end
  
  describe 'transaction_date' do
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:transaction_date))
      expect(creator).to have(1).error_on(:transaction_date)
    end

    it 'should be a date, or a date-parsable string' do
      creator = TransactionItemCreator.new(checking, attributes)
      expect(creator.transaction_date).to eq(Date.civil(2013, 1, 1))
    end
  end
  
  describe 'description' do
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:description))
      expect(creator).to have(1).error_on(:description)
    end
  end
  
  describe 'other_account_id' do
    let (:invalid_account) { FactoryGirl.create(:account) }
    
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:other_account_id))
      expect(creator).to have(1).error_on(:other_account_id)
    end
    
    it 'should belong to the same entity as the creating account' do
      creator = TransactionItemCreator.new(checking, attributes.merge(other_account_id: invalid_account.id))
      expect(creator).to have(1).error_on(:other_account_id)
    end
  end
  
  describe 'amount' do
    it 'should be required' do
      creator = TransactionItemCreator.new(checking, attributes.without(:amount))
      expect(creator).to have(1).error_on(:amount)
    end

    context 'for an asset account' do
      let (:account) { FactoryGirl.create(:asset_account) }

      it 'should be positive with a debit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, debit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be > 0
      end

      it 'should be negative with a credit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, credit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be < 0
      end
    end

    context 'for an expense account' do
      let (:account) { FactoryGirl.create(:expense_account) }

      it 'should be positive with a debit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, debit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be > 0
      end

      it 'should be negative with a credit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, credit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be < 0
      end
    end

    context 'for a liability account' do
      let (:account) { FactoryGirl.create(:liability_account) }

      it 'should be negative with a debit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, debit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be < 0
      end

      it 'should be positive with a credit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, credit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be > 0
      end
    end

    context 'for an equtiy account' do
      let (:account) { FactoryGirl.create(:equity_account) }

      it 'should be negative with a debit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, debit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be < 0
      end

      it 'should be positive with a credit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, credit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be > 0
      end
    end

    context 'for an income account' do
      let (:account) { FactoryGirl.create(:income_account) }

      it 'should be negative with a debit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, debit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be < 0
      end

      it 'should be positive with a credit action' do
        transaction = FactoryGirl.create(:transaction, amount: 100, credit_account: account)
        transaction_item = transaction.items.select { |i| i.account == account }.first
        creator = TransactionItemCreator.new(transaction_item)
        expect(creator.amount).to be > 0
      end
    end
  end
  
  
  describe 'create' do
    it 'should create a new transaction item with valid attributes' do
      creator = TransactionItemCreator.new(checking, attributes)
      item = creator.create
      expect(item).not_to be_nil
      expect(item).to respond_to :account
      expect(item.account).to eq(checking)
      expect(item).to respond_to :amount
      expect(item.amount).to eq(100)
      expect(item).to respond_to :action
      expect(item.action).to eq(TransactionItem.credit)
      expect(item).to respond_to :transaction
      expect(item.owning_transaction).to respond_to :transaction_date
      expect(item.owning_transaction.transaction_date).to eq(Date.civil(2013, 1, 1))
      expect(item.owning_transaction).to respond_to :description
      expect(item.owning_transaction.description).to eq('Market Street')
    end
    
    it 'should return null with invalid attributes' do
      creator = TransactionItemCreator.new(checking, attributes.without(:description))
      expect(creator.create).to be_nil
    end

    it 'should adjust credit and debit actions for negative amounts' do
      item = TransactionItemCreator.new(checking, attributes.merge(amount: 100)).create
      expect(item.amount).to eq(100)
      expect(item.action).to eq(TransactionItem.debit)
    end

    it 'should adjust credit and debit actions for the account type' do
      car_loan = FactoryGirl.create(:liability_account, entity: checking.entity)
      item = TransactionItemCreator.new(car_loan, attributes.merge(other_account: checking, amount: -100)).create
      expect(item.amount).to eq(100)
      expect(item.action).to eq(TransactionItem.debit)

      other_item = item.owning_transaction.items.select { |i| i != item }.first
      expect(other_item.amount).to eq(100)
      expect(other_item.action).to eq(TransactionItem.credit)
    end
  end
  
  describe 'create!' do
    it 'should create a new transaction item with valid attributes' do
      creator = TransactionItemCreator.new(checking, attributes)
      item = creator.create!
      expect(item).not_to be_nil
      expect(item).to respond_to :account
      expect(item.account).to eq(checking)
      expect(item).to respond_to :amount
      expect(item.amount).to eq(100)
      expect(item).to respond_to :action
      expect(item.action).to eq(TransactionItem.credit)
      expect(item).to respond_to :transaction
      expect(item.owning_transaction).to respond_to :transaction_date
      expect(item.owning_transaction.transaction_date).to eq(Date.civil(2013, 1, 1))
      expect(item.owning_transaction).to respond_to :description
      expect(item.owning_transaction.description).to eq('Market Street')
    end
    
    it 'should raise InvalidStateError with invalid attributes' do
      creator = TransactionItemCreator.new(checking, attributes.without(:description))
      expect { creator.create! }.to raise_error(Money::InvalidStateError)
    end
  end
  
  describe 'update' do
    it 'should return true for success' do
      creator = TransactionItemCreator.new(transaction_item, attributes)
      expect(creator.update).to be true
    end
    
    it 'should update the specified transaction with the specified description' do
      creator = TransactionItemCreator.new(transaction_item, attributes)
      expect do
        creator.update
        transaction.reload
      end.to change(transaction, :description).from('Kroger').to('Market Street')
    end
    
    it 'should update the specified transaction with the specified transaction date' do
      creator = TransactionItemCreator.new(transaction_item, attributes)
      expect do
        creator.update
        transaction.reload
      end.to change(transaction, :transaction_date).from(Date.parse('2013-02-27')).to(Date.parse('2013-01-01'))
    end
    
    it 'should update the specified transaction item with the specified amount' do
      creator = TransactionItemCreator.new(transaction_item, attributes)
      expect do
        creator.update
        transaction_item.reload
      end.to change(transaction_item, :amount).from(BigDecimal.new(25)).to(BigDecimal.new(100))
    end
  end
end
