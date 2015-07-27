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

      accounts = if ENV['ACCOUNT']
                   account = entity.accounts.find_by(name: ENV['ACCOUNT'])
                   raise "Unable to find an account named #{ENV['ACCOUNT']}" unless account
                   [account]
                 else
                   entity.accounts
                 end
      LOGGER.debug "Updating #{accounts.length} account(s) in #{entity.name}"
      entity.defer_balance_recalculations do
        accounts.each do |account|
          LOGGER.debug "Updating account #{account.name}"
          account.rebuild_transaction_item_links
        end
      end
    else
      LOGGER.error "EMAIL and ENTITY must be specified"
    end
  end

  desc 'Finds loops in transaction item linked lists (required: EMAIL, ENTITY. optional: ACCOUNT)'
  task :find_link_loop => :environment do
    unless %w(EMAIL ENTITY).all?{|k| ENV[k]}
      LOGGER.error "EMAIL, and ENTITY are required"
    else
      user = User.find_by(email: ENV['EMAIL'])
      entity = user.entities.find_by(name: ENV['ENTITY'])
      accounts = if ENV['ACCOUNT']
                   [entity.accounts.find_by(name: ENV['ACCOUNT'])]
                 else
                   entity.accounts
                 end
      loops = accounts.map{|a| find_loop(a)}.compact
      LOGGER.info "Found #{loops.count} loop(s)"
      loops.each do |item|
        LOGGER.info "#{item.account.path}\n  #{item.previous_transaction_item_id}->#{item.id}->#{item.next_transaction_item_id}"
      end
    end
  end

  def find_loop(account)
    puts ""
    found = Set.new
    account.transaction_items_backward.each do |item|
      if found.include?(item.id)
        return item
      else
        found << item.id
      end
      print '.'
    end
    nil
  end
end
