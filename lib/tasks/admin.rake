namespace :admin do
  LOGGER = Logger.new(STDOUT)

  # --------------
  # Update balance
  # --------------
  
  desc 'Recalculates the current balance for all accounts (options: ENTITY & EMAIL)'
  task :update_balances => :environment do
    accounts = if ENV['EMAIL'] && ENV['ENTITY']
                 user = User.find_by(email: ENV['EMAIL'])
                 raise "Unable to find a user with email #{ENV['EMAIL']}" unless user

                 entity = user.entities.find_by(name: ENV['ENTITY'])
                 raise "Unable to find an entity named #{ENV['ENTITY']}" unless entity

                 LOGGER.debug "Updating accounts in #{entity.name}"
                 entity.accounts
               else
                 LOGGER.debug "Updating all accounts"
                 Account.find(:all)
               end
    accounts.each do |account|
      account.recalculate_balances
      LOGGER.info "called update_balances on account #{account.name}"
    end
  end
end
