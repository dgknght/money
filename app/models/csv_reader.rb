require 'csv'

# Lazily reads a CSV file, yielding a hash for each row with keys
# based on the first row of the file
class CsvReader
  include Enumerable

  def initialize(data)
    @data = data
  end

  def each
    CSV.parse(@data.read) do |row|
      if @header
        yield to_hash(row)
      else
        @header = row
      end
    end
  end

  def to_hash(row)
    HashWithIndifferentAccess.new.tap do |h|
      row.each_with_index do |value, index|
        h[@header[index].to_sym] = value
      end
    end
  end
end
