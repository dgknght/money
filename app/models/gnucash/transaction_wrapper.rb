# Wrapper around GnucashTransactionData
module Gnucash
  class TransactionWrapper
    def commodity_transaction?
      items.any?{|i| i.action}
    end

    def date_posted
      @source["trn:date-posted"]["ts:date"]
    end

    def initialize(source, importer)
      @source = source
      @importer = importer
    end

    def items
      @items ||= parse_items
    end

    def method_missing(m, *args, &block)
      @source[to_key(m)]
    end

    def split_transaction?
      items.one?
    end

    def transfer_transaction?
      items.all?{|i| i.has_key?("split:action")}
    end

    private

    def parse_items
      raw = @source["trn:splits"]["trn:split"]
      raw = [raw] if raw.is_a?(Hash)
      raw.map{|i| TransactionItemWrapper.new(i, @importer)}
    end

    def to_key(method_name)
      "trn:#{method_name}"
    end
  end

  # Wraps a hash of transaction item attributes
  class TransactionItemWrapper
    def method_missing(m, *args, &block)
      @source[to_key(m)]
    end

    def account
      @account ||= Account.find(account_id)
    end

    def account_id
      @account_id ||= lookup_account_id
    end

    def initialize(source, importer)
      @source = source
      @importer = importer
    end

    def quantity
      number_value("split:quantity")
    end

    def value
      number_value("split:value")
    end

    private

    def lookup_account_id
      external_id = @source["split:account"]
      @importer.lookup_account_id(external_id)
    end

    def number_value(key)
      GnucashImporter.parse_amount(@source[key])
    end

    def to_key(method_name)
      "split:#{method_name.to_s.gsub('_', '-')}"
    end
  end
end
