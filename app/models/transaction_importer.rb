#Imports transactions
class TransactionImporter
  include ActiveModel::Validations

  attr_accessor :entity, :data

  validates_presence_of :entity, :data

  def initialize(params = {})
    params ||= {}
    @entity = params[:entity]
    @data = params[:data]
  end
end
