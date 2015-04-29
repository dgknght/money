# Managers the transfer for an equity lot from one account to another
class LotTransfer
  include ActiveModel::Validations

  attr_accessor :source_account, :target_account, :lot

  validates_presence_of :source_account, :target_account, :lot

  def initialize(options = {})
    @source_account = options[:source_account]
    @target_account = options[:target_account]
    @lot = options[:lot]
  end

  def transfer
  end
end
