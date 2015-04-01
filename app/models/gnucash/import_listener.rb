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
end