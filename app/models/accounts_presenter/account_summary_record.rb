class AccountSummaryRecord
  include Enumerable

  attr_reader :caption

  def <<(record)
    @records << record
  end

  def balance
    @records.select { |r| r.depth == 1 }.
      reduce(0) { |sum, record| sum + record.balance }
  end

  def depth
    0
  end

  def each
    ([self] + @records).each { |r| yield r }
  end

  def initialize(caption, records)
    @caption = caption
    @records = records
  end
end
