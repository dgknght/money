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

  def lookup_account_id(source_id, raise_error_if_not_found = false)
    return nil unless source_id
    result = account_map[source_id]
    if raise_error_if_not_found && result.nil?
      raise "Unable to find an account with source_id=#{source_id}"
    end
    result
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
  def self.parse_amount(input)
    return nil unless input.present?
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
      if account.errors.count == 1 and account.errors[:name] == ["has already been taken"]
        # Account is a duplicate, point to the existing account with the same name
        existing = account.parent.children.find_by(name: account.name)
        raise "Unable to find the duplicate #{source.inspect}" unless existing
        account_map[source["act:id"]] = existing.id
      else
        cannot_save account, :name, source
      end
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
    amount = GnucashImporter.parse_amount(source["price:value"])
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
    transaction = Gnucash::TransactionWrapper.new(source)
    if transaction.commodity_transaction?
      save_commodity_transaction(transaction)
    else
      save_regular_transaction(transaction)
    end
    @trace_method.call 't'
  end

  def save_commodity_transaction(source)
    if source.split_transaction?
      save_commodity_split_transaction(source)
    elsif source.transfer_transaction?
      save_commodity_transfer_transaction(source)
    else
      save_standard_commodity_transaction(source)
    end
  end

  def save_commodity_split_transaction(source)
    item = source.items.first
    quantity_added = item.quantity

    account_id = lookup_account_id(item.account)
    account = Account.find(account_id)

    shares_owned = account.lots.reduce(0){|sum, l| sum + l.shares_owned}

    commodity = @entity.commodities.find_by(symbol: account.name)

    CommoditySplitter.new(numerator: shares_owned + quantity_added,
                          denominator: shares_owned,
                          commodity: commodity).split!
  end

  def save_standard_commodity_transaction(source)
    commodities_item = source.items.select{|i| i.action.nil?}.first
    commodities_account_id = lookup_account_id(commodities_item.account)

    # points to the account that tracks purchases of a commodity within the investment account
    commodity_item = source.items.select{|i| i.action}.first
    commodity_account_id = lookup_account_id(commodity_item.account, true)
    commodity_account = Account.find(commodity_account_id)

    creator = CommodityTransactionCreator.new(account_id: commodities_account_id,
                                              commodities_account_id: commodity_account.parent_id,
                                              transaction_date: source.date_posted,
                                              action: commodity_item.action.downcase,
                                              symbol: commodity_account.name,
                                              shares: commodity_item.quantity.abs,
                                              value: commodity_item.value.abs)
    creator.create!
  rescue StandardError => e
    Rails.logger.error "Unable to save the commodity transaction:\n  source=#{source.inspect},\n  creator=#{creator.inspect}\n  #{e.message}\n  #{e.backtrace.join("\n    ")}"
    raise e
  end

  def save_commodity_transfer_transaction(source)
    items = source.items.map do |i|
      {
        quantity: i.quantity,
        account: Account.find(lookup_account_id(i["split:account"]))
      }
    end.sort_by{|i| i[:quantity]}

    items.first[:account].lots.each do |lot|
      LotTransfer.new(lot: lot, target_account_id: items.second[:account].parent_id).transfer!
    end
  end

  def save_regular_transaction(source)
    description = "blank" unless source.description.present?
    transaction = @entity.transactions.new(transaction_date: source.date_posted,
                                           description: source.description)

    source.items.
      map{|i| transaction_item_attributes(i)}.
      compact.
      each{|h| transaction.items.new(h)}

    if transaction.items.any?
      cannot_save(transaction, :description, source) unless transaction.save
    end
  rescue => e
    Rails.logger.error "Unable to save the regular transaction #{source.inspect}"
    raise e
  end

  def transaction_item_attributes(item_source)
    amount = item_source.value ? item_source.value : 0
    return nil if amount.zero?

    {
      amount: amount.abs,
      account_id: lookup_account_id(item_source.account),
      action: amount < 0 ? TransactionItem.credit : TransactionItem.debit,
      reconciled: item_source.reconciled_state == 'y'
    }
  rescue => e
    Rails.logger.error "Unable to transform the transaction item attributes #{item_source.inspect}"
    raise e
  end

  def gzip_reader
    # The following was necessary to get the unit tests and
    # usage through a web browse to work
    to_read = data.respond_to?(:tempfile) ? data.tempfile : data
    Zlib::GzipReader.open(to_read)
  end
end
