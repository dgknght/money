class AccountSummaryRecord
  include Enumerable

  attr_reader :caption

  def <<(record)
    @records << record if record
  end

  def account
    nil
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

  def identifier
    "summary_#{caption}"
  end

  def initialize(caption, records)
    @caption = caption
    @records = records
  end
end
