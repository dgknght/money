# Wrapper around GnucashTransactionData
module Gnucash
  class TransactionWrapper
    def commodity_transaction?
      items.any?{|i| i.action}
    end

    def date_posted
      @source["trn:date-posted"]["ts:date"]
    end

    def initialize(source)
      @source = source
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
      raw.map{|i| TransactionItemWrapper.new(i)}
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

    def initialize(source)
      @source = source
    end

    private

    def to_key(method_name)
      "split:#{method_name.to_s.gsub('_', '-')}"
    end
  end
end
