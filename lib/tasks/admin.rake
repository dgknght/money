namespace :admin do
  LOGGER = Logger.new(STDOUT)

  # --------------
  # Update balance
  # --------------
  
  desc 'Recalculates the current balance for all accounts'
  task :update_balance => :environment do
    Account.find(:all).each do |account|
      LOGGER.debug "recalculating balance for account #{account.name}"

      before = account.balance
      account.recalculate_balance

      LOGGER.info "updated balance of account #{account.name} from #{before} to #{account.balance}"
    end
  end
end
