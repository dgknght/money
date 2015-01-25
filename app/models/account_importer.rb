# Imports accounts
class AccountImporter
  include ActiveModel::Validations

  attr_accessor :data

  validates_presence_of :data

  def import
  end

  def initialize(params = {})
    @data = (params || {})[:data]
  end
end
