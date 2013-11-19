# Builds a transaction given information from
# the prespective of a given account
class TransactionItemCreator
  include ActiveModel::Validations
  
  attr_accessor :transaction_date, :description, :other_account, :amount, :other_account_id
  
  validates_presence_of :transaction_date, :description, :other_account, :amount
  validate :other_account_belongs_to_right_entity
  
  def create
    raise Money::InvalidStateError unless valid?
    
    transaction = @account.entity.transactions.new( transaction_date: transaction_date,
                                                    description: description)
    result = transaction.items.new(account: @account, amount: amount, action: TransactionItem.credit)
    transaction.items.new(account: other_account, amount: amount, action: TransactionItem.debit)
    transaction.save!
    result
  end
  
  def initialize(account, attributes = {})
    attributes ||= attributes.with_indifferent_access
    @account = account
    self.transaction_date = as_date(attributes[:transaction_date])
    self.description = attributes[:description]
    self.other_account = attributes[:other_account]
    self.amount = attributes[:amount]
  end
  
  private
    def as_date(value)
      return Date.parse(value) if value.is_a? String
      value
    end
    
    def other_account_belongs_to_right_entity
      return unless other_account
      errors.add(:other_account, 'must belong to the same entity as "account"') unless other_account.entity.id == @account.entity.id
    end
end