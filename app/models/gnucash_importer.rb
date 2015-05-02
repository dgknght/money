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

  ELEMENTS_TO_PROCESS = ["gnc:account", "gnc:commodity", "price", "gnc:transaction"]

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

    name = content_type == Account.commodity_content ?
      source["act:commodity"]["cmdty:id"] :
      source["act:name"]

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

  # The amount comes in as a fraction, like 200000/100
  def parse_amount(input)
    numerator, denominator = input.split('/')
    BigDecimal.new(numerator) / BigDecimal.new(denominator)
  end

  def prices_read
    @prices_read ||= Set.new
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
    simple_name = name.rpartition(':')[2]
    method_name = "process_#{simple_name}_element".to_sym
    if respond_to?(method_name, true)
      send method_name, elem
    else
      Rails.logger.error "Unrecognized element #{name}, #{elem.inspect}"
    end
  end

  def process_price_element(source)
    amount = parse_amount(source["price:value"])
    return unless amount > 0

    symbol = source["price:commodity"]["cmdty:id"]
    trade_date = source["price:time"]["ts:date"].to_date
    key = "#{symbol}:#{trade_date}"
    unless prices_read.include?(key)
      commodity = @commodities[symbol]
      price = commodity.prices.new(trade_date: trade_date,
                                   price: amount)

      if price.save(validate: false) # skip validation for performance reasons
        prices_read << key
        @trace_method.call 'p'
      else
        Rails.logger.warn "Unable to import the price.\n  source=#{source.inspect}\n  #{price.errors.full_messages.to_sentence}"
      end
    end
  rescue StandardError => e
    Rails.logger.warn "Unable to import the price.\n  source=#{source.inspect}\n  #{e.message}\n  #{e.backtrace.join("\n    ")}"
  end

  def process_transaction_element(source)
    if commodity_transaction?(source)
      save_commodity_transaction(source)
    else
      save_regular_transaction(source)
    end
    @trace_method.call 't'
  end

  def transaction_items(source)
    items = source["trn:splits"]["trn:split"]
    items.is_a?(Hash) ? [items] : items
  end

  def commodity_transaction?(source)
    transaction_items(source).any?{|i| i.has_key?("split:action")}
  end

  def save_commodity_transaction(source)
    if split_transaction?(source)
      save_commodity_split_transaction(source)
    elsif transfer_transaction?(source)
      save_commodity_transfer_transaction(source)
    else
      save_standard_commodity_transaction(source)
    end
  end

  def transfer_transaction?(source)
    source_items = transaction_items(source)
    source_items.all?{|i| i.has_key?("split:action")}
  end

  def split_transaction?(source)
    source_items = transaction_items(source)
    source_items.one?
  end

  def save_commodity_split_transaction(source)
    item = transaction_items(source).first
    quantity_added = parse_amount(item["split:quantity"])

    account_id = lookup_account_id(item["split:account"])
    account = Account.find(account_id)

    shares_owned = account.lots.reduce(0){|sum, l| sum + l.shares_owned}

    commodity_account_id = lookup_account_id(item["split:account"])
    commodity_account = Account.find(commodity_account_id)
    commodity = @entity.commodities.find_by(symbol: commodity_account.name)

    CommoditySplitter.new(numerator: shares_owned + quantity_added,
                          denominator: shares_owned,
                          commodity: commodity).split!
  end

  def save_standard_commodity_transaction(source)
    source_items = transaction_items(source)
    commodities_item = source_items.select{|i| !i.has_key?("split:action")}.first
    commodities_account_id = lookup_account_id(commodities_item["split:account"])

    # points to the account that tracks purchases of a commodity within the investment account
    commodity_item = source_items.select{|i| i.has_key?("split:action")}.first
    commodity_account_id = lookup_account_id(commodity_item["split:account"])
    commodity_account = Account.find(commodity_account_id)

    creator = CommodityTransactionCreator.new(account_id: commodities_account_id,
                                              commodities_account_id: commodity_account.parent_id,
                                              transaction_date: source["trn:date-posted"]["ts:date"],
                                              action: commodity_item["split:action"].downcase,
                                              symbol: commodity_account.name,
                                              shares: parse_amount(commodity_item["split:quantity"]).abs,
                                              value: parse_amount(commodity_item["split:value"]).abs)
    creator.create!
  rescue StandardError => e
    Rails.logger.error "Unable to save the commodity transaction:\n  source=#{source.inspect},\n  creator=#{creator.inspect}\n  #{e.message}\n  #{e.backtrace.join("\n    ")}"
    raise e
  end

  def save_commodity_transfer_transaction(source)
    source_items = transaction_items(source)
    items = source_items.map do |i|
      {
        quantity: parse_amount(i["split:quantity"]),
        account: Account.find(lookup_account_id(i["split:account"]))
      }
    end.sort_by{|i| i[:quantity]}

    items.first[:account].lots.each do |lot|
      LotTransfer.new(lot: lot, target_account_id: items.second[:account].parent_id).transfer!
    end
  end

  def save_regular_transaction(source)
    description = source["trn:description"]
    description = "blank" unless description.present?
    transaction = @entity.transactions.new(transaction_date: source["trn:date-posted"]["ts:date"],
                                           description: description)
    source["trn:splits"]["trn:split"].each do |item_source|
      amount = parse_amount(item_source["split:value"])
      transaction.items.new(account_id: lookup_account_id(item_source["split:account"]),
                            action: amount < 0 ? TransactionItem.credit : TransactionItem.debit,
                            amount: amount.abs,
                            reconciled: item_source["split:reconciled-state"] == 'y')
    end

    cannot_save(transaction, :description, source) unless transaction.save
  end

  def gzip_reader
    # The following was necessary to get the unit tests and
    # usage through a web browse to work
    to_read = data.respond_to?(:tempfile) ? data.tempfile : data
    Zlib::GzipReader.open(to_read)
  end
end
