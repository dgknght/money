# Creates, updates, and deletes transactions, ensuring that all
# necessary balance adjustments are made
class TransactionManager

  def initialize(entity)
    raise 'An entity must be specified' unless entity
    @entity = entity
  end

  def create!(attributes)
    transaction = @entity.transactions.new(attributes)
    ActiveRecord::Base.transaction do
      transaction.items.group_by(&:account).each { |account, items| process_new_item_group(account, items) }
      transaction.save!
    end
    transaction
  end

  private

  # Returns all of the items in the account associated with the
  # transaction item that occur before the date of the transaction
  # to which the specified item belongs.
  #
  # Called during processing of a new transaction
  def after_items_by_date(item)
    ids = item.account.
      transaction_items.
      occurring_on_or_after(item.transaction_date).
      map(&:id)
    TransactionItem.find(ids)
  end

  # Process new items in a transaction having the same account
  def process_new_item_group(_, items)
    first_item = items.first
    before_item = first_item.account.transaction_items.occurring_before(first_item.transaction_date).first
    last_index = before_item.try(:index) || 0
    last_balance = (before_item.try(:balance) || BigDecimal.new(0))

    items.each do |item|
      last_index = item.index = last_index + 1
      last_balance = item.balance = last_balance + item.polarized_amount
    end

    after_items_by_date(first_item).each do |after_item|
      last_index = after_item.index = last_index + 1
      last_balance = after_item.balance = last_balance + after_item.polarized_amount
      after_item.save!
    end

    first_item.account.balance = last_balance
    first_item.account.save!
  end
end
