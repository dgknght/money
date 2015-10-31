namespace :admin do
  LOGGER = Logger.new(STDOUT)

  # --------------
  # Update balance
  # --------------

  desc 'Rebuilds transaction item indexes for the specified account, or all accounts for the entity (required: ENTITY & EMAIL, optional: ACCOUNT)'
  task :reindex_transaction_items=> :environment do
    if ENV['EMAIL'] && ENV['ENTITY']
      user = User.find_by(email: ENV['EMAIL'])
      raise "Unable to find a user with email #{ENV['EMAIL']}" unless user

      entity = user.entities.find_by(name: ENV['ENTITY'])
      raise "Unable to find an entity named #{ENV['ENTITY']}" unless entity

      accounts = if ENV['ACCOUNT']
                   account = entity.accounts.find_by(name: ENV['ACCOUNT'])
                   raise "Unable to find an account named #{ENV['ACCOUNT']}" unless account
                   [account]
                 else
                   entity.accounts
                 end
      LOGGER.debug "Updating #{accounts.length} account(s) in #{entity.name}"
      #entity.defer_balance_recalculations do
        accounts.each do |account|
          LOGGER.debug "Updating account #{account.name}"
          account.recalculate_balances!
        end
      #end
    else
      LOGGER.error "EMAIL and ENTITY must be specified"
    end
  end

  desc 'Recalculates balances for all accounts for an entity (required: EMAIL & ENTITY)'
  task :recalculate_balances => :environment do
    user = User.find_by(email: ENV['EMAIL'])
    raise "Unable to find a user with email #{ENV['EMAIL']}" unless user

    entity = user.entities.find_by(name: ENV['ENTITY'])
    raise "Unable to find an entity named #{ENV['ENTITY']}" unless entity

    entity.recalculate_all_account_balances
  end
end
