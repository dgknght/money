class TransactionItemUpdater
  include ActiveModel::Validations
  
  attr_accessor :transaction_item, :description, :transaction_date, :amount, :other_account_id
  
  validates_presence_of :transaction_item
  
  def initialize(transaction_item, attributes = {})
    self.transaction_item = transaction_item
    attributes = (attributes || {}).with_indifferent_access
    self.description = attributes[:description]
    self.transaction_date = attributes[:transaction_date]
    self.amount = attributes[:amount]
    self.other_account_id = attributes[:other_account_id]
  end
  
  def update
    return false unless valid?
    update_transaction
    transaction.save
  end
  
  private
    def other_item
      transaction_item.transaction.items.select{ |i| i.id != transaction_item.id }.first
    end
    
    def transaction
      transaction_item.transaction
    end
    
    def update_transaction
      if amount
        transaction_item.amount = amount
        other_item.amount = amount
      end
      transaction.transaction_date = transaction_date if transaction_date
      transaction.description = description if description
      other_item.account_id = other_account_id if other_account_id
    end
end
