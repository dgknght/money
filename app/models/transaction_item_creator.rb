# Builds a transaction given information from
# the prespective of a given account
class TransactionItemCreator
  include ActiveModel::Validations
  
  attr_accessor :transaction_date, :description, :other_account, :amount, :other_account_id
  
  validates_presence_of :transaction_date, :description, :other_account_id, :amount
  validate :other_account_belongs_to_right_entity
  
  def create
    return nil unless valid?
    create_transaction_item
  end
  
  def create!
    raise Money::InvalidStateError unless valid?
    create_transaction_item
  end
  
  def initialize(account_or_transaction_item = nil, attributes = {})
    attributes ||= attributes.with_indifferent_access
    if account_or_transaction_item.is_a?(Account)
      @account = account_or_transaction_item
    else
      @transaction_item = account_or_transaction_item
      @account = @transaction_item.account
    end
    attributes = (attributes || {}).with_indifferent_access
    
    self.transaction_date = as_date(attributes[:transaction_date]) || (@transaction_item ? @transaction_item.transaction.transaction_date : nil)
    self.description = attributes[:description] || (@transaction_item ? @transaction_item.transaction.description : nil)
    self.other_account_id = attributes[:other_account_id] || (@transaction_item ? other_item.account_id : nil)
    self.other_account = Account.find(other_account_id) if other_account_id
    self.amount = attributes[:amount] || (@transaction_item ? @transaction_item.amount : nil)
  end
  
  def update
    return false unless valid?
    update_transaction_item
  end
  
  private
    def as_date(value)
      return nil unless value
      return parse_date(value) if value.is_a? String
      value
    end
    
    def create_transaction_item
      transaction = @account.entity.transactions.new( transaction_date: transaction_date,
                                                      description: description)
      result = transaction.items.new(account: @account, amount: amount, action: TransactionItem.credit)
      transaction.items.new(account: other_account, amount: amount, action: TransactionItem.debit)
      transaction.save!
      result
    end
    
    def other_account_belongs_to_right_entity
      return unless other_account
      errors.add(:other_account_id, 'must belong to the same entity as "account"') unless other_account.entity.id == @account.entity.id
    end
    
    def other_item
      return nil unless @transaction_item
      @transaction_item.transaction.items.select{ |i| i.account_id != @transaction_item.account_id }.first
    end
    
    #TODO This should be in a more sharable location
    def parse_date(value)
      match_data = /^(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{2,4})$/.match(value)
      return Date.civil(match_data[:year].to_i, match_data[:month].to_i, match_data[:day].to_i) if match_data
      Date.parse(value)      
    end
    
    def update_transaction_item
      @transaction_item.transaction.description = description if description
      @transaction_item.transaction.transaction_date = transaction_date if transaction_date
      @transaction_item.transaction.items.each { |i| i.amount = amount } if amount
      if other_account
        other_item.account = other_account
      end
      @transaction_item.transaction.save!
    end
end