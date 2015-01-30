#Imports transactions
class TransactionImporter
  include ActiveModel::Validations

  attr_accessor :entity, :data

  validates_presence_of :entity, :data

  def initialize(params = {})
    params ||= {}
    @entity = params[:entity]
    @data = params[:data]
  end

  def import
    TransactionReader.new(CsvReader.new(data)).each do |t|
      puts "t=#{t.inspect}"
    end
  end

  class TransactionReader
    include Enumerable

    def initialize(reader)
      @reader = reader
    end

    TransactionRecord = Struct.new(:transaction_date, :description, :items)
    ItemRecord = Struct.new(:amount, :account, :number, :memo)
    def each
      @reader.each do |row|
        if row["Date"].present?
          yield @transaction if @transaction
          @transaction = TransactionRecord.new(Chronic.parse(row["Date"]), row["Description"], [])
        else
          @transaction.items << ItemRecord.new(BigDecimal.new(row["From Num."]),
                                               row["Category"],
                                               row["Number"],
                                               row["Memo"])
        end
      end
      yield @transaction if @transaction
    end
  end
end
