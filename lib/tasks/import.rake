namespace :import do
  desc 'Import data from a gnucash file (options: EMAIL, ENTITY_NAME, PATH'
  task :gnucash => :environment do
    Rails.logger = Logger.new(STDOUT)

    user = User.find_by_email(ENV['EMAIL'])
    if user
      entity_name = ENV['ENTITY_NAME'] || 'gnucash'

      existing = user.entities.find_by(name: entity_name)
      existing.fast_destroy! if existing.present?

      entity = user.entities.new(name: entity_name)
      unless entity.save
        logger.warn "Unable to save the entity #{entity.inspect}: #{entity.errors.full_messages.to_sentence}"
        return
      end

      importer = GnucashImporter.new(entity: entity,
                                     data: File.open(ENV['PATH']),
                                     trace_method: ->(m){print m})
      if importer.valid?
        prof_result = nil
        result = Benchmark.measure do
          prof_result = RubyProf.profile do
            importer.import!
          end
        end

        prof_result.eliminate_methods! [/Nokogiri/]
        printer = RubyProf::GraphPrinter.new(prof_result)
        File.open(Rails.root.join("reports", "money_profile.txt"), "w") do |f|
          printer.print(f, min_percent: 2)
        end

        puts ""
        puts result
      else
        Rails.logger.warn "Unable to perform the import: #{importer.errors.full_messages.to_sentince}"
      end
    else
      Rails.logger.warn "Unable to perform the import: no user with email #{ENV['EMAIL']}"
    end
  end
end
