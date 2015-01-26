require 'csv'

# Imports accounts
class AccountImporter
  include ActiveModel::Validations

  TYPE_MAP = { "BANK" => Account.asset_type,
               "CREDIT" => Account.liability_type,
               "INCOME" => Account.income_type,
               "EXPENSE" => Account.expense_type,
               "EQUITY" => Account.equity_type,
               "CASH" => Account.asset_type }
  attr_accessor :data, :entity

  validates_presence_of :data, :entity

  def import
    Reader.new(data).
        select{|r| r[:place_holder] != 'T'}.
        reject{|r| %w(Imbalance-USD Orphan-USD).include?(r[:full_name])}.
      each do |row|
      entity.accounts.create!(name: row[:name], account_type: TYPE_MAP[row[:type]])
    end
  end

  def initialize(params = {})
    @data = (params || {})[:data]
  end

  # TODO Move this to a library

  # Reads a CSV file, yielding a hash for each row with keys
  # based on the first row of the file
  class Reader
    include Enumerable

    def initialize(data)
      @data = data
    end

    def each
      CSV.parse(@data.read) do |row|
        if @header
          yield to_hash(row)
        else
          @header = row
        end
      end
    end

    def to_hash(row)
      Hash.new.tap do |h|
        row.each_with_index do |value, index|
          h[@header[index].to_sym] = value
        end
      end
    end
  end
end
