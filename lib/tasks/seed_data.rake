namespace :seed_data do

  LOGGER = Logger.new(STDOUT)

  # -----
  # Users
  # -----
  
  desc 'Loads the database with sample users'
  task :users => :environment do
    email = ENV['email'] || 'john@doe.com'
    if User.find_by_email(email)
      LOGGER.info "user with email #{email} already exists"
    else
      user = User.create!(email: email, password: 'please01', password_confirmation: 'please01')
      LOGGER.info "created user #{user.email}"
    end
  end
  
  # --------
  # Entities
  # --------
  
  desc 'Loads the database with sample entities'
  task :entities => :users  do
    user = User.first
    if user.entities.find_by_name('Personal')
      LOGGER.info "entity 'Personal' already exists"
    else
      entity = FactoryGirl.create(:entity, user_id: user.id, name: 'Personal')
      LOGGER.info "created entity #{entity.name}"
    end
  end

  # --------
  # Accounts
  # --------
  
  AccountDef = Struct.new(:name, :type, :children)
  
  def create_account(entity, account_def, parent = nil)
    return if entity.accounts.find_by_name(account_def.name)
    
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

  # ------
  # Budget
  # ------
  
  def create_budget_item(budget, account_name, amount_per_month)
    account = budget.entity.accounts.find_by_name(account_name)
    budget_item = budget.items.new(account_id: account.id)
    distributor = BudgetItemDistributor.new(budget_item)
    distributor.apply_attributes(method: BudgetItemDistributor.average, options: { amount: amount_per_month })
    distributor.distribute
    budget_item.save!
    LOGGER.info "created budget item for account #{account.name}"
  end
  
  desc 'Creates a sample budget'
  task :budget => :accounts do
    entity = Entity.first

    if entity.budgets.find_by_name('2013')
      LOGGER.info "Budget 2013 already exists"
    else
      budget = entity.budgets.create!(name: '2013', start_date: '2013-01-01', period: Budget.month, period_count: 12)
      create_budget_item(budget, 'Salary', 10_000)
      create_budget_item(budget, 'Groceries', 320)
      create_budget_item(budget, 'Gasoline', 120)
      create_budget_item(budget, 'Mortgage Interest', 899)
    end
  end
  
  # ------------
  # Transactions
  # ------------

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
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Opening Balances', action: 'credit', amount: 2_000}, {account: 'Checking', action: 'debit', amount: 2_000}]),
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Opening Balances', action: 'credit', amount: 200_000}, {account: 'Home', action: 'debit', amount: 200_000}]),
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Opening Balances', action: 'credit', amount: 10_000}, {account: 'Car', action: 'debit', amount: 10_000}]),
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Opening Balances', action: 'credit', amount: 30_000}, {account: 'Reserve', action: 'debit', amount: 30_000}]),
      TransactionDef.new('2013-01-01', 'Opening Balance', [{account: 'Home Loan', action: 'credit', amount: 175_000}, {account: 'Opening Balances', action: 'debit', amount: 175_000}]),
      
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
      TransactionDef.new('2013-01-01', 'Mortgage Co.', [{account: 'Checking', action: 'credit', amount: 1000}, {account: 'Mortgage Interest', action: 'debit', amount: 900}, {account: 'Home Loan', action: 'debit', amount: 100}]),
      TransactionDef.new('2013-02-01', 'Mortgage Co.', [{account: 'Checking', action: 'credit', amount: 1000}, {account: 'Mortgage Interest', action: 'debit', amount: 899}, {account: 'Home Loan', action: 'debit', amount: 101}]),
      TransactionDef.new('2013-03-01', 'Mortgage Co.', [{account: 'Checking', action: 'credit', amount: 1000}, {account: 'Mortgage Interest', action: 'debit', amount: 898}, {account: 'Home Loan', action: 'debit', amount: 102}]),
      
      # Credit Card
      TransactionDef.new('2013-01-08', 'Master Charge', [{account: 'Checking', action: 'credit', amount: 500}, {account: 'Credit Card', action: 'debit', amount: 500}]),
      TransactionDef.new('2013-02-08', 'Master Charge', [{account: 'Checking', action: 'credit', amount: 500}, {account: 'Credit Card', action: 'debit', amount: 500}]),
      TransactionDef.new('2013-03-08', 'Master Charge', [{account: 'Checking', action: 'credit', amount: 500}, {account: 'Credit Card', action: 'debit', amount: 500}])
    ]
    transaction_defs.each { |t| create_transaction(entity, t) }
  end
  
end
