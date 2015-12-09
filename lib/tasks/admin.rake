namespace :admin do
  LOGGER = Logger.new(STDOUT)

  # --------------
  # Update balance
  # --------------

  desc 'Recalculates balances for all accounts for an entity (required: EMAIL & ENTITY)'
  task :recalculate_balances => :environment do
    user = User.find_by(email: ENV['EMAIL'])
    raise "Unable to find a user with email #{ENV['EMAIL']}" unless user

    entity = user.entities.find_by(name: ENV['ENTITY'])
    raise "Unable to find an entity named #{ENV['ENTITY']}" unless entity

    entity.recalculate_all_account_balances
  end
end
