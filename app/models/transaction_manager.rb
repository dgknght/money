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

  def delete!(transaction)
    items = transaction.items.to_a
    ActiveRecord::Base.transaction do
      transaction.destroy!
      account_deltas = items.
        group_by(&:account).
        flat_map do |account, _|
          process_items_as_of(account, transaction.transaction_date)
      end
      process_account_deltas(account_deltas)
    end
  end

  def update!(transaction)
    ActiveRecord::Base.transaction do
      processing_date = [transaction.transaction_date, transaction.transaction_date_was].min
      dereferenced_accounts = get_dereferenced_accounts(transaction)

      transaction.save!
      account_deltas = transaction.items.
        group_by(&:account).
        flat_map do |account, _|
          process_items_as_of(account, processing_date)
      end

      account_deltas += dereferenced_accounts.flat_map do |account|
        process_items_as_of(account, processing_date)
      end

      process_account_deltas(account_deltas)
    end
  end

  private

  # Return a list of accounts that used to be referenced by one or
  # more items in the transaction, but that are now no longer referenced
  def get_dereferenced_accounts(transaction)
    current_account_ids = transaction.items.map(&:account_id)
    old_accounts = transaction.items.
      lazy.
      reject(&:destroyed?).
      select(&:account_id_changed?).
      map(&:account_id_was).
      reject{|id| current_account_ids.include?(id)}.
      map{|id| Account.find(id)}.
      to_a
  end

  # Given a list of maps where the keys are accounts
  # and the values are deltas, aggregate the deltas by
  # account, then update the children_balance for each
  # account with the aggregation of the deltas
  def process_account_deltas(deltas)
    deltas.
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

  def process_item_sequence(account, basis_item, items, after_items)
    last_index = basis_item.try(:index) || -1
    last_balance = basis_item.try(:balance) || BigDecimal.new(0)

    last_index, last_balance = process_items(items, last_index, last_balance)
    last_index, last_balance = process_items(after_items, last_index, last_balance, true)

    delta = last_balance - account.balance
    account.balance = last_balance
    account.save!

    account.parents.map do |parent|
      { account: parent, delta: delta }
    end.reject{|d| d[:delta] == 0}
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
    process_item_sequence(account, basis_item, items, after_items)
  end

  def process_items_as_of(account, as_of_date)
    basis_item = account.first_transaction_item_occurring_before(as_of_date)
    basis_index = basis_item.try(:index) || -1
    basis_balance = basis_item.try(:balance) || BigDecimal.new(0)
    # The following should sort at the database layer, but for some reason it wouldn't for the test suite
    items = account.transaction_items_occurring_on_or_after(as_of_date).sort_by{|i| i.transaction.transaction_date}

    process_item_sequence(account, basis_item, [], items)
  end
end
