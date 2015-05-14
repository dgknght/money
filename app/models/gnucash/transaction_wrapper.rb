# Wrapper around GnucashTransactionData
module Gnucash
  class TransactionWrapper
    def all_items
      @all_items ||= parse_items
    end

    def commodity_transaction?
      items.any?{|i| i.account.commodity?}
    end

    def date_posted
      @source["trn:date-posted"]["ts:date"]
    end

    def exchange_transaction?
      items.count == 2 && items.all?{|i| i.account.commodity?} && items.map(&:parent_id).uniq.count == 1
    end

    def ignorable_transaction?
      items.none?
    end

    def inspect
      @source.inspect
    end

    def initialize(source, importer)
      @source = source
      @importer = importer
    end

    def items
      @items ||= all_items.select(&:has_value?)
    end

    def method_missing(m, *args, &block)
      @source[to_key(m)]
    end

    def split_transaction?
      items.one? && items.first.action == "Split"
    end

    def to_s
      @source.to_s
    end

    def transfer_transaction?
      items.count == 2 && items.all?{|i| i.account.commodity?}
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

    def has_value?
      quantity != 0 || value != 0
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
