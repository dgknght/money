# Base class from which reports that aggregate account balances
# are derived
class Report
  include ActionView::Helpers::NumberHelper
  
  #TODO It may be better to separate the logic for flattening from the balance calculation
  
  # Flattens the account hierarchy calculating a
  # balance using the specified method and arguments
  def flatten(accounts, depth, filter, method, *args)
    accounts.select{|a| filter.call(a)}.map do |account|
      [
        { account: account, depth: depth, balance: account.send(method, *args) },
        flatten(account.children, depth + 1, filter, method, *args)
      ]
    end.flatten
  end
  
  # Formats the value as a currency without any unit specification
  def format(value)
    number_to_currency(value, unit: '')
  end    
  
  # Calculates the sum of the balance for each row
  def sum(rows)
    rows.select{ |row| row[:depth] == 1 }.reduce(0) { |sum, row| sum += row[:balance]}
  end
  
  # Prepares the records for final presentation by
  # replacing the full account with the account name
  # and formatting the balance
  def transform(records)
    records.map do |record|
      {
        account: record[:account].name,
        balance: format(record[:balance]),
        depth: record[:depth]
      }
    end
  end
end
