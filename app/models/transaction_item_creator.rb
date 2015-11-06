# Builds a transaction given information from
# the prespective of a given account
class TransactionItemCreator
  include ActiveModel::Validations
  
  attr_accessor :transaction_date, :description, :amount, :other_account_id
  
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
    attributes = (attributes || {}).with_indifferent_access
    if account_or_transaction_item.is_a?(Account)
      @account = account_or_transaction_item
    else
      @transaction_item = read_from_transaction(account_or_transaction_item)
      @account = @transaction_item.account
    end
    
    self.transaction_date = as_date(attributes[:transaction_date]) || (@transaction_item ? @transaction_item.transaction_date : nil)
    self.description = attributes[:description] || (@transaction_item ? @transaction_item.owning_transaction.description : nil)
    self.other_account_id = attributes[:other_account_id] || (@transaction_item ? other_item.account_id : nil)
    self.other_account = attributes[:other_account] if attributes.has_key?(:other_account)
    self.amount = attributes[:amount].try(:to_f) || (@transaction_item ? @transaction_item.polarized_amount : nil)
  end
  
  def other_account
    @other_account ||= find_account(self.other_account_id)
  end

  def other_account=(account)
    @other_account = account;
    self.other_account_id = account ? account.id : nil
  end

  def other_account_id=(id)
    @other_account_id = id
    @other_account = nil
  end

  def update
    return false unless valid?
    update_transaction_item
    true
  end
  
  private
    def as_date(value)
      return nil unless value
      return parse_date(value) if value.is_a? String
      value
    end
    
    def create_transaction_item
      result = nil
      Transaction.transaction do
        transaction = @account.entity.transactions.new( transaction_date: transaction_date,
                                                        description: description)
        result = transaction.items.new(account: @account,
                                      amount: amount.abs,
                                      action: @account.infer_action(amount))
        transaction.items.new(account: other_account,
                              amount: amount.abs,
                              action: TransactionItem.opposite_action(result.action))
        TransactionManager.new(transaction).create!
      end
      result
    end

    def find_account(id)
      return nil unless id
      Account.find(id)
    end
    
    def other_account_belongs_to_right_entity
      return unless other_account
      errors.add(:other_account_id, 'must belong to the same entity as "account"') unless other_account.entity.id == @account.entity.id
    end
    
    def other_item
      return nil unless @transaction_item
      @transaction_item.owning_transaction.items.select{ |i| i.account_id != @transaction_item.account_id }.first
    end
    
    #TODO This should be in a more sharable location
    def parse_date(value)
      match_data = /^(?<month>\d{1,2})\/(?<day>\d{1,2})\/(?<year>\d{2,4})$/.match(value)
      return Date.civil(match_data[:year].to_i, match_data[:month].to_i, match_data[:day].to_i) if match_data
      Date.parse(value)      
    end
    
    # Get a reference to the same item as the transaction to avoid having two instance of the same item
    def read_from_transaction(item)
      item.owning_transaction.items.select { |i| i.id == item.id }.first
    end

    def update_transaction_item
      Transaction.transaction do
        @transaction_item.owning_transaction.description = description if description
        @transaction_item.owning_transaction.transaction_date = transaction_date if transaction_date
        other_item.account = other_account if other_account
        if amount
          @transaction_item.amount = amount.abs
          @transaction_item.action = @transaction_item.account.infer_action(amount)
          other_item.amount = amount.abs
          other_item.action = TransactionItem.opposite_action(@transaction_item.action)
        end
        TransactionManager.new(@transaction_item.owning_transaction).update!
      end
    end
end
