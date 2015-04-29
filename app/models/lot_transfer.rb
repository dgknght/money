# Managers the transfer for an equity lot from one account to another
class LotTransfer
  include ActiveModel::Validations

  attr_accessor :target_account, :lot

  validates_presence_of :target_account, :lot

  def initialize(options = {})
    @target_account = options[:target_account]
    @lot = options[:lot]
  end

  def transfer
    lot.account_id = commodity_target_account.id
    lot.save
  end

  private

  def commodity_target_account
    @commodity_target_account ||= find_or_create_account
  end

  def find_or_create_account
    target_account.children.find_by_name(lot.commodity.symbol) ||
      target_account.children.create!(name: lot.commodity.symbol,
                                      entity: target_account.entity,
                                      account_type: Account.asset_type,
                                      content_type: Account.commodity_content)
  end
end
