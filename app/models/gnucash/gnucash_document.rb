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
      end
    end

    def characters(value)
      @last_content = value
    end

    def end_element(name)
      case name
      when "gnc:account"
        @listener.account_read(@account)
      when /^act:(.*)/
        @account[$1] = @last_content
      end
    end
  end
end
