# Reads transactions from the given CSV reader
class TransactionReader
  include Enumerable

  def initialize(reader)
    @reader = reader
  end

  TransactionRecord = Struct.new(:transaction_date, :description, :items)
  ItemRecord = Struct.new(:to_amount, :from_amount, :account, :number, :memo)
  def each
    @reader.each do |row|
      if row["Date"].present?
        yield @transaction if @transaction
        @transaction = TransactionRecord.new(Chronic.parse(row["Date"]), row["Description"], [])
      else
        @transaction.items << ItemRecord.new(BigDecimal.new(row["To Num."].gsub(',', '')),
                                             BigDecimal.new(row["From Num."].gsub(',', '')),
                                             row["Category"],
                                             row["Number"],
                                             row["Memo"])
      end
    end
    yield @transaction if @transaction
  end
end
