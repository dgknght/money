namespace :seed_data do

  LOGGER = Logger.new(STDOUT)

  # -----
  # Users
  # -----
  
  desc 'Loads the database with sample users'
  task :users => :environment do
    email = ENV['email'] || 'john@doe.com'
    user = User.create!(email: email, password: 'please01', password_confirmation: 'please01')
    LOGGER.info "created user #{user.email}"
  end
  
  # --------
  # Entities
  # --------
  
  desc 'Loads the database with sample entities'
  task :entities => :users  do
    user = User.first
    entity = FactoryGirl.create(:entity, user_id: user.id, name: 'Personal')
    LOGGER.info "created entity #{entity.name}"
  end

  # --------
  # Accounts
  # --------
  
  AccountDef = Struct.new(:name, :type, :children)
  
  def create_account(entity, account_def, parent = nil)
    account = FactoryGirl.create( :account, 
                                  entity_id: entity.id, 
                                  name: account_def.name, 
                                  account_type: account_def.type, 
                                  parent_id: parent.nil? ? nil : parent.id)
    LOGGER.info "created account #{account.name}"
    
    return account unless account_def.children
    
    account_def.children.each do |child|
      create_account entity, child, account
    end
  end
  
  desc 'Loads the database with sample accounts'
  task :accounts => :entities do
    entity = Entity.first

    account_defs = [
      AccountDef.new('Checking', 'asset'),
      AccountDef.new('Home', 'asset'),
      AccountDef.new('Savings', 'asset', [AccountDef.new('Car', 'asset'), AccountDef.new('Reserve', 'asset')]),
      AccountDef.new('Credit Card', 'liability'),
      AccountDef.new('Home Loan', 'liability'),
      AccountDef.new('Opening Balances', 'equity'),
      AccountDef.new('Gift', 'income'),
      AccountDef.new('Salary', 'income'),
      AccountDef.new('Gasoline', 'expense'),
      AccountDef.new('Groceries', 'expense'),
      AccountDef.new('Mortgage Interest', 'expense'),
      AccountDef.new('Dining', 'expense'),
    ]
    account_defs.each { |a| create_account(entity, a) }
  end

  # --------
  # Accounts
  # --------

  TransactionDef = Struct.new(:date, :description, :items)
  
  def create_transaction(entity, transaction_def)
    transaction_def.items.each do |i|
      i[:account_id] = entity.accounts.find_by_name(i[:account]).id
      i.delete :account
    end
    transaction = entity.transactions.create!(transaction_date: Date.parse(transaction_def.date), description: transaction_def.description, items_attributes: transaction_def.items)
    LOGGER.info "created transaction #{transaction.transaction_date} #{transaction.description}"
  end
  
  desc 'Loads the database with sample transactions'
  task :transactions => :accounts do
    entity = Account.first.entity
    
    transaction_defs = [
    
      # Opening balances
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Opening Balances', action: 'credit', amount: 2000}, {account: 'Checking', action: 'debit', amount: 2000}]),
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Opening Balances', action: 'credit', amount: 200000}, {account: 'Home', action: 'debit', amount: 200000}]),
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Opening Balances', action: 'credit', amount: 10000}, {account: 'Car', action: 'debit', amount: 10000}]),
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Opening Balances', action: 'credit', amount: 30000}, {account: 'Reserve', action: 'debit', amount: 30000}]),
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Home Loan', action: 'credit', amount: 175000}, {account: 'Opening Balances', action: 'debit', amount: 175000}]),
      
      # Paycheck
      TransactionDef.new('2013-01-01', 'Paycheck', [{account: 'Salary', action: 'credit', amount: 5000}, {account: 'Checking', action: 'debit', amount: 5000}]),
      TransactionDef.new('2013-01-15', 'Paycheck', [{account: 'Salary', action: 'credit', amount: 5000}, {account: 'Checking', action: 'debit', amount: 5000}]),
      TransactionDef.new('2013-02-01', 'Paycheck', [{account: 'Salary', action: 'credit', amount: 5000}, {account: 'Checking', action: 'debit', amount: 5000}]),
      TransactionDef.new('2013-02-15', 'Paycheck', [{account: 'Salary', action: 'credit', amount: 5000}, {account: 'Checking', action: 'debit', amount: 5000}]),
      TransactionDef.new('2013-03-01', 'Paycheck', [{account: 'Salary', action: 'credit', amount: 5000}, {account: 'Checking', action: 'debit', amount: 5000}]),
      TransactionDef.new('2013-03-15', 'Paycheck', [{account: 'Salary', action: 'credit', amount: 5000}, {account: 'Checking', action: 'debit', amount: 5000}]),
      
      # Groceries
      TransactionDef.new('2013-01-06', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-01-13', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-01-20', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-01-27', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-02-03', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-02-10', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-02-17', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-02-24', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-03-03', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-03-10', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-03-17', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-03-24', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      TransactionDef.new('2013-03-31', 'Kroger', [{account: 'Credit Card', action: 'credit', amount: 80}, {account: 'Groceries', action: 'debit', amount: 80}]),
      
      # Gasoline
      TransactionDef.new('2013-01-07', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-01-14', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-01-21', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-01-28', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-02-04', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-02-11', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-02-18', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-02-25', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-03-04', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-03-11', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-03-18', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      TransactionDef.new('2013-03-25', 'Chevron', [{account: 'Credit Card', action: 'credit', amount: 40}, {account: 'Gasoline', action: 'debit', amount: 40}]),
      
      # Mortgate
      TransactionDef.new('2013-01-01', 'Bank', [{account: 'Checking', action: 'credit', amount: 1000}, {account: 'Mortgage Interest', action: 'debit', amount: 900}, {account: 'Home Loan', action: 'debit', amount: 100}]),
      TransactionDef.new('2013-02-01', 'Bank', [{account: 'Checking', action: 'credit', amount: 1000}, {account: 'Mortgage Interest', action: 'debit', amount: 899}, {account: 'Home Loan', action: 'debit', amount: 101}]),
      TransactionDef.new('2013-03-01', 'Bank', [{account: 'Checking', action: 'credit', amount: 1000}, {account: 'Mortgage Interest', action: 'debit', amount: 898}, {account: 'Home Loan', action: 'debit', amount: 102}]),
      
      # Credit Card
      TransactionDef.new('2013-01-08', 'Bank', [{account: 'Checking', action: 'credit', amount: 150}, {account: 'Credit Card', action: 'debit', amount: 150}]),
      TransactionDef.new('2013-02-08', 'Bank', [{account: 'Checking', action: 'credit', amount: 150}, {account: 'Credit Card', action: 'debit', amount: 150}]),
      TransactionDef.new('2013-03-08', 'Bank', [{account: 'Checking', action: 'credit', amount: 150}, {account: 'Credit Card', action: 'debit', amount: 150}])
    ]
    transaction_defs.each { |t| create_transaction(entity, t) }
  end
  
end