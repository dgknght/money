# Imports GnuCash files into the system
class GnucashImporter
  include ActiveModel::Validations

  TYPE_MAP = {"BANK"   => Account.asset_type,
    "CREDIT" => Account.liability_type,
    "CASH"   => Account.asset_type,
    "STOCK"  => Account.asset_type,
    "MUTUAL" => Account.asset_type}

  CONTENT_TYPE_MAP = {"STOCK"  => Account.commodity_content,
    "MUTUAL" => Account.commodity_content}
  IGNORE_ACCOUNTS = ["Root Account", "Assets", "Liabilities", "Expenses", "Income", "Equity"]

  ELEMENTS_TO_PROCESS = ["gnc:account", "gnc:commodity"]

  attr_accessor :data, :entity
  validates_presence_of :data, :entity

  def initialize(options = {})
    @data = options[:data]
    @entity = options[:entity]
    @trace_method = options[:trace_method] || ->(m){}
    @commodities = {}
  end

  def import!
    return unless valid?
    doc = HashingDocument.new(->(n, e) { process_element(n, e) }, *ELEMENTS_TO_PROCESS)
    parser = Nokogiri::XML::SAX::Parser.new(doc)
    parser.parse(gzip_reader)
  end

  private

  def account_map
    @account_map ||= {}
  end

  def cannot_save(resource, display_attribute, source)
    Rails.logger.error "Unable to save the #{resource.class.name}" +
      "\n  resource=#{resource.inspect}" +
    "\n  source=#{source.inspect}" +
    "\n  errors=#{resource.errors.full_messages.to_sentence}"
    raise "Unable to save the #{resource.class.name} \"#{resource.send(display_attribute)}\"."
  end

  def ignore_account?(name)
    IGNORE_ACCOUNTS.include?(name)
  end

  def lookup_account_id(source_id)
    return nil unless source_id
    account_map[source_id]
  end

  def map_account_attributes(source)
    content_type = map_account_content_type(source["act:type"])

    name_keys = content_type == Account.commodity_content ? ["act:code", "act:name"] : ["act:name"]
    name = name_keys.map{|k| source[k]}.select{|name| name}.first

    account = @entity.accounts.new(name: name,
                                   account_type: map_account_type(source["act:type"]),
                                   content_type: content_type,
                                   parent_id: lookup_account_id(source["act:parent"]))
  end

  def map_account_content_type(type)
    CONTENT_TYPE_MAP.fetch(type, Account.currency_content)
  end

  def map_account_type(type)
    TYPE_MAP.fetch(type, type.downcase)
  end

  def process_account_element(source)
    return if ignore_account?(source["act:name"])

    account = map_account_attributes(source)
    if account.save
      account_map[source["act:id"]] = account.id
      @trace_method.call 'a'
    else
      cannot_save account, :name, source unless account.errors.count == 1 and account.errors[:name].count == 1
      return
    end

    account.parent.update_attribute(:content_type, Account.commodities_content) if account.commodity? && !account.parent.commodities?
  end

  def process_commodity_element(source)
    # ignore USD and template
    return if %w(USD template).include?(source["cmdty:id"])

    commodity = @entity.commodities.new(name: source["cmdty:name"],
                                        symbol: source["cmdty:id"],
                                        market: source["cmdty:space"])

    if commodity.save
      @commodities[commodity.symbol] = commodity
      @trace_method.call 'c'
    else
      cannot_save(commodity, :name, source)
    end
  end

  def process_element(name, elem)
    if name == "gnc:account"
      process_account_element(elem)
    elsif name == "gnc:commodity"
      process_commodity_element(elem)
    else
      puts "process_element #{name}, #{elem.inspect}"
    end
  end

  def gzip_reader
    # The following was necessary to get the unit tests and
    # usage through a web browse to work
    to_read = data.respond_to?(:tempfile) ? data.tempfile : data
    Zlib::GzipReader.open(to_read)
  end
end
