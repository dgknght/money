class TransactionItemCreator
  include ActiveModel::Validations
  
  attr_accessor :transaction_date, :description
  
  validates_presence_of :transaction_date, :description
  
  def initialize(account, attributes = {})
    attributes ||= attributes.with_indifferent_access
    @account = account
    self.transaction_date = as_date(attributes[:transaction_date])
    self.description = attributes[:description]
  end
  
  private
    def as_date(value)
      return Date.parse(value) if value.is_a? String
      value
    end
end