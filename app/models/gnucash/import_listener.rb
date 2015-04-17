module Gnucash
  # Listener that watches a SAX parser that parses GnuCash files
  # and responds to the data that the parser finds
  class ImportListener
    TYPE_MAP = {"BANK"   => Account.asset_type,
                "CREDIT" => Account.liability_type,
                "CASH"   => Account.asset_type,
                "STOCK"  => Account.asset_type,
                "MUTUAL" => Account.asset_type}

    CONTENT_TYPE_MAP = {"STOCK"  => Account.commodity_content,
                        "MUTUAL" => Account.commodity_content}

    IGNORE_ACCOUNTS = ["Root Account", "Assets", "Liabilities", "Expenses", "Income", "Equity"]

    def account_map
      @account_map ||= {}
    end

    def map_account_attributes(source)
      content_type = map_account_content_type(source[:type])

      name_keys = content_type == Account.commodity_content ? [:code, :name] : [:name]
      name = name_keys.map{|k| source[k]}.select{|name| name}.first

      account = @entity.accounts.new(name: name,
                                     account_type: map_account_type(source[:type]),
                                     content_type: content_type,
                                     parent_id: lookup_account_id(source[:parent]))
    end

    def account_read(source)
      return if ignore_account?(source[:name])

      account = map_account_attributes(source)
      if account.save
        account_map[source[:id]] = account.id
        @trace_method.call 'a'
      else
        cannot_save account, :name, source unless account.errors.count == 1 and account.errors[:name].count == 1
        return
      end

      account.parent.update_attribute(:content_type, Account.commodities_content) if account.commodity? && !account.parent.commodities?
    end

    def commodity_read(source)
      # ignore USD and template
      return if %w(USD template).include?(source[:id])

      commodity = @entity.commodities.new(name: source[:name],
                                          symbol: source[:id],
                                          market: source[:space])

      if commodity.save
        @commodities[commodity.symbol] = commodity
        @trace_method.call 'c'
      else
        cannot_save(commodity, :name, source)
      end
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

    def initialize(entity, trace_method = ->(m){})
      @entity = entity
      @commodities = {}
      @trace_method = trace_method
    end

    def lookup_account_id(source_id)
      return nil unless source_id
      account_map[source_id]
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

    def price_read(source)
      amount = parse_amount(source[:value])
      return unless amount > 0

      symbol = source[:commodity][:id]
      trade_date = source[:time].to_date
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

    def transaction_read(source)
      if commodity_transaction?(source)
        save_commodity_transaction(source)
      else
        save_regular_transaction(source)
      end
      @trace_method.call 't'
    end

    def commodity_transaction?(source)
      source[:items].any?{|i| i.has_key?(:action)}
    end

    def save_commodity_transaction(source)
      # points to the account use to pay for purchases, and that received proceeds from sales
      commodities_item = source[:items].select{|i| !i.has_key?(:action)}.first
      commodities_account_id = lookup_account_id(commodities_item[:account])

      # points to the account that tracks purchases of a commodity within the investment account
      commodity_item = source[:items].select{|i| i.has_key?(:action)}.first
      commodity_account_id = lookup_account_id(commodity_item[:account])
      commodity_account = Account.find(commodity_account_id)

      creator = CommodityTransactionCreator.new(account_id: commodities_account_id,
                                                commodities_account_id: commodity_account.parent_id,
                                                transaction_date: source["date-posted"],
                                                action: commodity_item[:action].downcase,
                                                symbol: commodity_account.name,
                                                shares: parse_amount(commodity_item[:quantity]).abs,
                                                value: parse_amount(commodity_item[:value]).abs)
      creator.create!
    rescue StandardError => e
      Rails.logger.error "Unable to save the commodity transaction:\n  source=#{source.inspect},\n  creator=#{creator.inspect}\n  #{e.backtrace.join("\n    ")}"
      raise e
    end

    def save_regular_transaction(source)
      description = source[:description]
      description = "blank" unless description.present?
      transaction = @entity.transactions.new(transaction_date: source[:"date-posted"],
                                             description: description)
      source[:items].each do |item_source|
        amount = parse_amount(item_source[:value])
        transaction.items.new(account_id: lookup_account_id(item_source[:account]),
                              action: amount < 0 ? TransactionItem.credit : TransactionItem.debit,
                              amount: amount.abs,
                              reconciled: item_source[:"reconciled-state"] == 'y')
      end

      cannot_save(transaction, :description, source) unless transaction.save
    end
  end

  class NullTracer
    def print(message); end
  end

  class ConsoleTracer
    def print(message)
      print message
    end
  end
end
