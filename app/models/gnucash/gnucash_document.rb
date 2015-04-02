# SAX parser that targets GnuCash files
module Gnucash
  class GnucashDocument < Nokogiri::XML::SAX::Document
    def initialize(listener)
      @listener = listener
    end

    def start_element(name, attrs=[])
      case name
      when "gnc:account"
        @account = HashWithIndifferentAccess.new
      when "gnc:transaction"
        @transaction = HashWithIndifferentAccess.new
      when "trn:splits"
        @transaction_items = []
      when "trn:split"
        @transaction_item = HashWithIndifferentAccess.new
      when /.*:(commodity|currency)$/
        @commodity = HashWithIndifferentAccess.new
      when "price"
        @price = HashWithIndifferentAccess.new
      end
    end

    def characters(value)
      @last_content = value
    end

    def end_element(name)
      finish_account_element(name) ||
        finish_transaction_element(name) ||
        finish_commodity_element(name) ||
        finish_price_element(name)
    end

    def finish_account_element(name)
      case name
      when "gnc:account"
        @listener.account_read(@account)
        @account = nil
        true
      when /^act:(.*)/
        @account[$1] = @last_content
        true
      end
      false
    end

    def finish_commodity_element(name)
      case name
      when /^cmdty:(.*)/
        @commodity[$1] = @last_content
        true
      when "gnc:commodity"
        @listener.commodity_read(@commodity)
        @commodity = nil
        true
      end
      false
    end

    def finish_price_element(name)
      case name
      when "price"
        @listener.price_read(@price)
        @price = nil
        true
      when /^price:(commodity|currency)$/
        @price[$1] = @commodity
        @commodity = nil
        true
      when "price:time"
        @price[:time] = @date
        true
      when /^price:(.*)/
        @price[$1] = @last_content
        true
      end
      false
    end

    def finish_transaction_element(name)
      case name
      when /^trn:(date-.*)/
        @transaction[$1] = @date
        true
      when "trn:split"
        @transaction_items << @transaction_item
        true
      when "trn:splits"
        @transaction[:items] = @transaction_items
        true
      when /^trn:(.*)/
        @transaction[$1] = @last_content
        true
      when /^split:(.*)/
        @transaction_item[$1] = @last_content
        true
      when "ts:date"
        @date = Chronic.parse(@last_content)
        true
      when "gnc:transaction"
        @listener.transaction_read(@transaction)
        @transaction = nil
        true
      end
      false
    end
  end
end
