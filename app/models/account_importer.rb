# Imports accounts
class AccountImporter
  include ActiveModel::Validations

  TYPE_MAP = { "BANK" => Account.asset_type,
               "CREDIT" => Account.liability_type,
               "CASH" => Account.asset_type }
  IGNORE = %w(Assets Liabilities Income Expenses Equity Imbalance-USD Orphan-USD)

  attr_accessor :data, :entity

  validates_presence_of :data, :entity

  def import
    return false unless valid?

    CsvReader.new(data).
        reject{|r| IGNORE.include?(r[:full_name])}.
      each do |row|
          parent = get_parent_from_full_name(row[:full_name])
          a = entity.accounts.new(name: row[:name],
                                  account_type: translate_type(row[:type]),
                                  parent: parent)
          unless a.save
            puts "unable to save account #{a.inspect}: #{a.errors.full_messages.to_sentence}"
          end
    end
  end

  def translate_type(import_type)
    TYPE_MAP[import_type] || import_type.downcase
  end
  private :translate_type

  def get_parent_from_full_name(full_name)
    # full name looks like Assets:Savings:Reserve
    # The first segment is the account type
    # The last segment is the child account
    # The rest are parent accounts
    segments = full_name.split(':').reverse.drop(1).reverse.drop(1)
    segments.present? ? Account.find_by_path(segments) : nil
  end
  private :get_parent_from_full_name

  def initialize(params = {})
    params = params || {}
    @data = params[:data]
    @entity = params[:entity]
  end
end