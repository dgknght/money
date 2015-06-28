namespace :admin do
  LOGGER = Logger.new(STDOUT)

  # --------------
  # Update balance
  # --------------
  
  desc 'Recalculates the current balance for all accounts (required: ENTITY & EMAIL)'
  task :update_balances => :environment do
    if ENV['EMAIL'] && ENV['ENTITY']
      user = User.find_by(email: ENV['EMAIL'])
      raise "Unable to find a user with email #{ENV['EMAIL']}" unless user

      entity = user.entities.find_by(name: ENV['ENTITY'])
      raise "Unable to find an entity named #{ENV['ENTITY']}" unless entity

      LOGGER.debug "Updating accounts in #{entity.name}"
      entity.recalculate_all_account_balances
    else
      LOGGER.error "EMAIL and ENTITY must be specified"
    end
  end

  desc 'Rebuilds the linked lists for transaction items for the specified entity (required: ENTITY & EMAIL)'
  task :rebuild_linked_lists => :environment do
    if ENV['EMAIL'] && ENV['ENTITY']
      user = User.find_by(email: ENV['EMAIL'])
      raise "Unable to find a user with email #{ENV['EMAIL']}" unless user

      entity = user.entities.find_by(name: ENV['ENTITY'])
      raise "Unable to find an entity named #{ENV['ENTITY']}" unless entity

      LOGGER.debug "Updating accounts in #{entity.name}"
      entity.defer_balance_recalculations do
        entity.accounts.each do |account|
          LOGGER.debug "Updating account #{account.name}"
          account.rebuild_transaction_item_links
        end
      end
    else
      LOGGER.error "EMAIL and ENTITY must be specified"
    end
  end
end
