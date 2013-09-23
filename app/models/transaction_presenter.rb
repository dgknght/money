# Class that filters transactions for presentation in the UI
class TransactionPresenter
  include Enumerable
  
  # Creates a new instance of TransactionPresenter
  # options contains two values, account and user
  def initialize(options = {})
    @account = options[:account]
    @entity = options[:entity]
  end
  
  def each(&block)
    filtered.each do |t|
      if block_given?
        block.call t
      else
        yield person
      end
    end
  end
  
  private
  
    def filtered
      return [] unless @entity
      
      result = @entity.transactions
      result = filter_by_account(result)
      filter_by_status(result)
    end
    
    def filter_by_status(transactions)
      transactions.select{ |t| !t.new_record? }
    end
    
    def filter_by_account(transactions)
      return transactions unless @account
      transactions.select do |t|
        t.items.where(account_id: @account.id).any?
      end
    end
end