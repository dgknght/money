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
    return false unless valid?
    Transaction.transaction do
      TransactionReader.new(CsvReader.new(data)).each{ |t| import_transaction(t)}
    end
    true
  rescue e
    flash[:error] = "Unable to import the transactions: #{e.message}"
    logger.error "Unable to import the transactions: #{e.inspect}"
    false
  end

  private

  def import_transaction(t)
    transaction = entity.transactions.new(transaction_date: t.transaction_date,
                                          description: t.description,
                                          items_attributes: t.items.map{ |i| translate_item(i)})
    transaction.save
  end

  def translate_item(i)
    amount = i.to_amount == 0 ? i.from_amount : i.to_amount
    { account: lookup_account(i.account),
      amount: amount.abs,
      action: amount < 0 ? TransactionItem.credit : TransactionItem.debit,
      memo: i.memo }
  end

  def lookup_account(name)
    entity.accounts.find_by_name(name) #TODO how to handle ambiguous names?
  end
end
