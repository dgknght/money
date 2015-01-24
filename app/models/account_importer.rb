# Imports accounts
class AccountImporter
  include ActiveModel::Validations

  def import
  end

  def initialize(params = {})
    @data = (params || {})[:data]
  end
end
