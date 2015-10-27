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

    transacted_transfer
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

  def transacted_transfer
    old_account = lot.account
    Lot.transaction do
      lot.account_id = commodity_target_account.id
      if lot.save
        old_account.recalculate_balances!
        lot.account.recalculate_balances!
        true
      else
        false
      end
    end
  end
end
