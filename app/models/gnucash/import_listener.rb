module Gnucash
  # Listener that watches a SAX parser that parses GnuCash files
  # and responds to the data that the parser finds
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

    def commodity_read(source)
      # ignore USD and template
      return if %w(USD template).include?(source[:id])

      commodity = @entity.commodities.new(name: source[:name],
                                          symbol: source[:id],
                                          market: source[:space])

      unless commodity.save
        raise "Unable to save the commodity \"#{commodity.name}\": #{commodity.errors.full_messages.to_sentence}"
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

    # The amount comes in as a fraction, like 200000/100
    def parse_amount(input)
      numerator, denominator = input.split('/')
      BigDecimal.new(numerator) / BigDecimal.new(denominator)
    end

    def transaction_read(source)
      transaction = @entity.transactions.new(transaction_date: source[:"date-posted"],
                                            description: source[:description])
      source[:items].each do |item_source|
        amount = parse_amount(item_source[:value])
        transaction.items.new(account_id: lookup_account_id(item_source[:account]),
                              action: amount < 0 ? TransactionItem.credit : TransactionItem.debit,
                              amount: amount.abs,
                              reconciled: item_source[:"reconciled_state"] == 'y')
      end

      unless transaction.save
        raise "Unable to save the transaction \"#{transaction.description}\": #{transaction.errors.full_messages.to_sentence}"
      end
    end
  end
end
