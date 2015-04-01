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
      end
    end

    def characters(value)
      @last_content = value
    end

    def end_element(name)
      finish_account_element(name) || finish_transaction_element(name)
    end

    def finish_account_element(name)
      case name
      when "gnc:account"
        @listener.account_read(@account)
        true
      when /^act:(.*)/
        @account[$1] = @last_content
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
        true
      end
      false
    end
  end
end
