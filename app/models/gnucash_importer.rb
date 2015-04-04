# Imports GnuCash files into the system
class GnucashImporter
  include ActiveModel::Validations
  attr_accessor :data, :entity
  validates_presence_of :data, :entity

  def initialize(options = {})
    @data = options[:data]
    @entity = options[:entity]
  end

  def import!
    return unless valid?
    parser = Nokogiri::XML::SAX::Parser.new(Gnucash::GnucashDocument.new(Gnucash::ImportListener.new(@entity)))
    parser.parse(gzip_reader)
    true
  rescue Exception => e
    Rails.logger.error "Unable to complete the import: #{e}\n#{e.backtrace.join("\n")}"
    false
  end

  def gzip_reader
    # The following was necessary to get the unit tests and
    # usage through a web browse to work
    to_read = data.respond_to?(:tempfile) ? data.tempfile : data
    Zlib::GzipReader.open(to_read)
  end
end
