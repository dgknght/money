# Organizes and summaries account information
# for display
class AccountsPresenter
  include Enumerable

  DisplayRecord = Struct.new(:caption, :balance)
  def each
    [
      DisplayRecord.new('Assets', 0),
      DisplayRecord.new('Liabilities', 0),
      DisplayRecord.new('Equity', 0),
      DisplayRecord.new('Income', 0),
      DisplayRecord.new('Expense', 0),
    ].each { |r| yield r }
  end

  def initialize(entity)
  end
end
