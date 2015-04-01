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
    puts "Exception: #{e}"
    false
  end

  def gzip_reader
    Zlib::GzipReader.open(data.tempfile)
  end
end
