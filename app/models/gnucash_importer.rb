# Imports GnuCash files into the system
class GnucashImporter
  include ActiveModel::Validations
  attr_accessor :data, :entity
  validates_presence_of :data, :entity

  def initialize(options = {})
    @data = options[:data]
    @entity = options[:entity]
  end

  def import!
    return unless valid?
    parser = Nokogiri::XML::SAX::Parser.new(GnucashDocument.new(ImportListener.new(@entity)))
    parser.parse(gzip_reader)
    true
  rescue
    false
  end

  def gzip_reader
    Zlib::GzipReader.open(data.tempfile)
  end

  class ImportListener
    TYPE_MAP = { "BANK" => Account.asset_type,
                 "CREDIT" => Account.liability_type,
                 "CASH" => Account.asset_type }
    IGNORE_ACCOUNTS = ["Root Account", "Assets", "Liabilities", "Expenses", "Income", "Equity"]

    def account_map
      @account_map ||= {}
    end

    def account_read(source)
      return if ignore_account?(source[:name])
      account = @entity.accounts.new(name: source[:name],
                                     account_type: map_account_type(source[:type]),
                                     parent_id: lookup_account_id(source[:parent]))
      if account.save
        account_map[source[:id]] = account.id
      else
        raise "Unable to save the account \"#{account.name}\": #{account.errors.full_messages.to_sentence}"
      end
    end

    def ignore_account?(name)
      IGNORE_ACCOUNTS.include?(name)
    end

    def initialize(entity)
      @entity = entity
    end

    def lookup_account_id(source_id)
      return nil unless source_id
      account_map[source_id]
    end

    def map_account_type(type)
      TYPE_MAP.fetch(type, type.downcase)
    end
  end

  class GnucashDocument < Nokogiri::XML::SAX::Document
    def initialize(listener)
      @listener = listener
    end

    def start_element(name, attrs=[])
      case name
      when "gnc:account"
        @account = HashWithIndifferentAccess.new
      end
    end

    def characters(value)
      @last_content = value
    end

    def end_element(name)
      case name
      when "gnc:account"
        @listener.account_read(@account)
      when /^act:(.*)/
        @account[$1] = @last_content
      end
    end
  end
end
