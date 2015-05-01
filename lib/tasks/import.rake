namespace :import do
  desc 'Import data from a gnucash file (options: EMAIL, ENTITY_NAME, PATH'
  task :gnucash => :environment do
    Rails.logger = Logger.new(STDOUT)

    user = User.find_by_email(ENV['EMAIL'])
    if user
      entity_name = ENV['ENTITY_NAME']

      existing = user.entities.find_by(name: entity_name)
      if existing.present?
        Entity.connection.execute("UPDATE transaction_items SET reconciled = false FROM transaction_items i INNER JOIN transactions t ON t.id = i.transaction_id WHERE t.entity_id = #{existing.id}")
        existing.destroy!
      end

      entity = user.entities.new(name: entity_name)
      unless entity.save
        logger.warn "Unable to save the entity #{entity.inspect}: #{entity.errors.full_messages.to_sentence}"
        return
      end

      importer = GnucashImporter.new(entity: entity,
                                     data: File.open(ENV['PATH']),
                                     trace_method: ->(m){print m})
      if importer.valid?
        importer.import!
      else
        Rails.logger.warn "Unable to perform the import: #{importer.errors.full_messages.to_sentince}"
      end
    else
      Rails.logger.warn "Unable to perform the import: no user with email #{ENV['EMAIL']}"
    end
  end
end
