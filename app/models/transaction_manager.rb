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
      account_deltas = transaction.items.
        group_by(&:account).
        flat_map do |account, items|
          process_new_item_group(account, items)
      end
      process_account_deltas(account_deltas)
      transaction.save!
    end
    transaction
  end

  def update!(transaction)
    ActiveRecord::Base.transaction do
      account_deltas = transaction.items.
        group_by(&:account).
        flat_map do |account, items|
          process_updated_item_group(account, items, transaction.transaction_date, transaction.transaction_date_was)
      end

      process_account_deltas(account_deltas)
      transaction.save!
    end
  end

  private

  # Returns all of the items in the account associated with the
  # transaction item that occur on or after the date of the transaction
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

  # Returns all of the itmes in the account associate with the
  # transaction item having an index greater than the specified 
  # item
  def after_items_by_index(item)
    item.account.transaction_items.where(['transaction_items."index" > ?', item.index])
  end

  # Given a list of maps where the keys are accounts
  # and the values are deltas, aggregate the deltas by
  # account, then update the children_balance for each
  # account with the aggregation of the deltas
  def process_account_deltas(deltas)
    grouped = deltas.
      group_by{|m| m[:account]}.
      map do |k, v|
        { account: k,
          delta: v.reduce(0) do |sum, m|
            sum + m[:delta]
          end }
      end.
      each do |m|
        account = m[:account]
        account.children_balance += m[:delta]
        account.save!
      end
  end

  def process_current_and_after_items(account, before_item, items, after_items)
    last_index = before_item.try(:index) || -1
    last_balance = before_item.try(:balance) || BigDecimal.new(0)

    last_index, last_balance = process_items(items, last_index, last_balance)
    last_index, last_balance = process_items(after_items, last_index, last_balance, true)

    delta = last_balance - account.balance
    account.balance = last_balance
    account.save!

    account.parents.map do |parent|
      { account: parent, delta: delta }
    end
  end

  # Given a list of items in index order, recalculate the
  # index and balance for each, returning an array containing
  # the last used index and last used balance
  def process_items(items, last_index, last_balance, save_item = false)
    items.each do |item|
      last_index = item.index = last_index + 1
      last_balance = item.balance = last_balance + item.polarized_amount
      item.save! if save_item
    end
    [last_index, last_balance]
  end

  # Process new items in a transaction having the same account
  # Return account deltas for every parent of the affected account
  # that will be used to recalculate 'children_balance' values
  def process_new_item_group(account, items)
    first_item = items.first
    before_item = account.transaction_items.occurring_before(first_item.transaction_date).first
    after_items = after_items_by_date(first_item)
    process_current_and_after_items(account, before_item, items, after_items)
  end

  def process_updated_item_group(account, items, new_date, old_date)
    sorted_items = items.sort_by(&:index)
    if new_date == old_date
      # This is just like process_new_item_group, expect we're address items by index instead of by transaction date
      first_item = sorted_items.first
      before_item = first_item.index == 0 ?
        nil :
        account.transaction_items.where(index: first_item.index - 1).first
      after_items = after_items_by_index(sorted_items.last)
      process_current_and_after_items(account, before_item, sorted_items, after_items)
    else
      []
    end
  end
end
