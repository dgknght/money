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

  def process_item_sequence(account, basis_item, before_items, items, after_items)
    last_index = basis_item.try(:index) || -1
    last_balance = basis_item.try(:balance) || BigDecimal.new(0)

    last_index, last_balance = process_items(before_items, last_index, last_balance, true)
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
    basis_item = account.first_transaction_item_occurring_before(first_item.transaction_date)
    after_items = first_item.account.transaction_items_occurring_on_or_after(first_item.transaction_date)
    process_item_sequence(account, basis_item, [], items, after_items)
  end

  def process_updated_item_group(account, items, new_date, old_date)
    sorted_items = items.sort_by(&:index)
    current_ids = sorted_items.map(&:id)
    first_item = sorted_items.first

    if new_date == old_date
      # position is unchanged
      basis_item = first_item.index == 0 ?
        nil :
        account.transaction_items.where(index: first_item.index - 1).first
      before_items = []
      after_items = after_items_by_index(sorted_items.last)
    elsif new_date < old_date
      # treat it just like a new item
      basis_item = account.first_transaction_item_occurring_before(first_item.transaction_date)
      before_items = []
      after_items = first_item.account.transaction_items_occurring_on_or_after(first_item.transaction_date).reject{|i| current_ids.include?(i.id)}
    else
      # items that were after but are now before must be corrected
      basis_item = account.first_transaction_item_occurring_before(old_date)
      before_items = account.transaction_items_occurring_between(old_date, new_date).reject{|i| current_ids.include?(i.id)}
      after_items = account.transaction_items_occurring_on_or_after(new_date).reject{|i| current_ids.include?(i.id)}
    end

    process_item_sequence(account, basis_item, before_items, sorted_items, after_items)
  end
end
