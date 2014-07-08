# Presents transaction items for an account, sorting
# them and calculating a running balance
class TransactionItemPresenter
  include Enumerable

  Record = Struct.new(:transaction_item, :balance)
  def each
    Wrapper.new(@account.transaction_items).
      transform.
      sort_ascending.
      calculate_balance.
      sort_descending.each { |r| yield r }
  end

  def initialize(account)
    @account = account
  end

  private

  #TODO This should be abstracted out for easy re-use
  class Wrapper
    include Enumerable

    def calculate_balance
      balance = 0
      calculated = @items.each do |record|
        balance += record.transaction_item.polarized_amount
        record.balance = balance
      end
      Wrapper.new(calculated)
    end

    def each
      @items.each { |i| yield i }
    end

    def initialize(items)
      @items = items
    end

    def sort_ascending
      Wrapper.new(@items.sort { |i1, i2| compare(i1, i2) })
    end

    def sort_descending
      Wrapper.new(@items.sort { |i1, i2| compare(i2, i1) })
    end

    def transform
      Wrapper.new(@items.map { |i| Record.new(i, 0) })
    end

    private

    def compare(item1, item2)
      date1, date2 = [item1, item2].map { |i| i.transaction_item.transaction.transaction_date }
      date1 <=> date2
    end
  end
end
