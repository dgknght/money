# Managers the transfer for an equity lot from one account to another
class LotTransfer
  include ActiveModel::Validations

  attr_accessor :target_account_id, :lot

  validates_presence_of :target_account_id, :lot

  def initialize(options = {})
    @target_account_id = options[:target_account_id]
    @lot = options[:lot]
  end

  def target_account
    @target_account ||= Account.find(target_account_id)
    @target_account
  end

  def transfer
    return false unless valid?

    lot.account_id = commodity_target_account.id
    lot.save
  end

  def transfer!
    raise "Unable to execute the transfer: #{errors.full_messages.to_sentence}" unless valid?
    transfer
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
