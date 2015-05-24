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

  def lookup_account_id(source_id, raise_error_if_not_found = false)
    return nil unless source_id
    result = account_map[source_id]
    if raise_error_if_not_found && result.nil?
      raise "Unable to find an account with source_id=#{source_id}"
    end
    result
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

  def ignore_account?(source)
    IGNORE_ACCOUNTS.include?(source['act:name']) ||
      source['act:type'] == 'ROOT' ||
      source['act:commodity']['cmdty:id'] == 'template'
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
    return if ignore_account?(source)

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
    transaction = Gnucash::TransactionWrapper.new(source, self)
    if transaction.commodity_transaction?
      save_commodity_transaction(transaction)
    else
      save_regular_transaction(transaction)
    end
  end

  def save_commodity_exchange_transaction(source)
    items = source.items.sort_by{|i| i.quantity}
    source_item = items.first
    target_item = items.last
    to_exchange = target_item.quantity
    commodity = @entity.commodities.find_by(symbol: target_item.account.name)

    source_item.account.lots.each do |lot|
      raise "Tried to exchange #{lot.shares_owned} shares, but the transaction only calls for #{to_exchange}" if to_exchange < lot.shares_owned
      to_exchange -= lot.shares_owned
      CommodityExchanger.new(lot: lot, commodity: commodity).exchange!
    end

    Rails.logger.warn "#{to_exchange} shares unexchanged for #{commodity.symbol}" unless to_exchange.zero?
    @trace_method.call 'x'
  rescue => e
    Rails.logger.error "Unable to save the commodity exchange transaction: #{e.message}\n  #{source}\n  #{e.backtrace.join("\n    ")}"
    raise e
  end

  def save_commodity_transaction(source)
    return if source.ignorable_transaction?

    if source.split_transaction?
      save_commodity_split_transaction(source)
    elsif source.exchange_transaction?
      save_commodity_exchange_transaction(source)
    elsif source.transfer_transaction?
      save_commodity_transfer_transaction(source)
    elsif source.items.one?
      puts "\nwhat to do with this? #{source}"
    else
      save_standard_commodity_transaction(source)
    end
  end

  def save_commodity_split_transaction(source)
    item = source.items.first
    shares_owned = item.account.lots.reduce(0){|sum, l| sum + l.shares_owned}
    commodity = @entity.commodities.find_by(symbol: item.account.name)

    CommoditySplitter.new(numerator: shares_owned + item.quantity,
                          denominator: shares_owned,
                          commodity: commodity).split!
    @trace_method.call 's'
  rescue => e
    Rails.logger.error "Unable to save the commodity split transaction:\n  source=#{source.inspect},\n  #{splitter.inspect},\n  #{e.message}\n  #{e.backtrace.join("\n    ")}"
    raise e
  end

  def save_standard_commodity_transaction(source)
    commodities_item = source.items.select{|i| !i.account.commodity?}.first

    # points to the account that tracks purchases of a commodity within the investment account
    commodity_item = source.items.select{|i| i.account.commodity?}.first
    commodity_account = commodity_item.account

    fee_item = source.items.select{|i| i.account.expense?}.first

    creator = CommodityTransactionCreator.new(account_id: commodities_item.account_id,
                                              commodities_account_id: commodity_account.parent_id,
                                              transaction_date: source.date_posted,
                                              action: commodity_item.action.downcase,
                                              symbol: commodity_account.name,
                                              shares: commodity_item.quantity.abs,
                                              fee: fee_item ? fee_item.value : 0,
                                              value: commodity_item.value.abs)
    creator.create!
    @trace_method.call 'o'
  rescue StandardError => e
    Rails.logger.error "Unable to save the commodity transaction:\n  source=#{source.inspect},\n  creator=#{creator.inspect}\n  #{e.message}\n  #{e.backtrace.join("\n    ")}"
    raise e
  end

  def save_commodity_transfer_transaction(source)
    items = source.items.sort_by{|i| i.quantity}
    target_account_id = items.second.account.parent_id
    items.first.account.lots.each do |lot|
      LotTransfer.new(lot: lot, target_account_id: target_account_id).transfer!
    end
    @trace_method.call 'r'
  rescue => e
    Rails.logger.error "Unable to save the commodity transfer transaction #{source.inspect}"
    raise e
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
    @trace_method.call 't'
  rescue => e
    Rails.logger.error "Unable to save the regular transaction #{source.inspect}"
    raise e
  end

  def transaction_item_attributes(item_source)
    amount = item_source.value || 0
    return nil if amount.zero?

    {
      amount: amount.abs,
      account_id: item_source.account_id,
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
