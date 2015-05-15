# Exchanges shares of on commodity for shares of another
class CommodityExchanger
  include ActiveModel::Validations

  attr_accessor :lot_id, :commodity_id

  validates_presence_of [:lot_id, :commodity_id]

  def commodity
    @commodity ||= Commodity.find(commodity_id)
  end

  def commodity=(c)
    self.commodity_id = c ? c.id : nil
    @commodity = c
  end

  def commodity_account
    @commodity_account ||= find_or_create_commodity_account
  end

  def lot
    @lot ||= Lot.find(lot_id)
  end

  def lot=(l)
    self.lot_id = l ? l.id : nil
    @lot = l
  end

  def exchange
    lot.commodity_id = commodity.id # go through the commodity object to be sure the commodity id is good
    lot.account_id = commodity_account.id
    lot.save
  end

  def exchange!
    raise "Cannot exchange the shares because of the following validation errors: #{errors.full_messages.to_sentence}" unless valid?
    exchange
  end

  def initialize(options = {})
    self.lot_id = options[:lot_id]
    self.lot = options[:lot] if options.has_key?(:lot)
    self.commodity_id = options[:commodity_id]
    self.commodity = options[:commodity] if options.has_key?(:commodity)
  end

  private

  # TODO This logic is largely duplicated in CommodityTransactionCreator. Should probably consolidate it
  def create_commodity_account
    lot.account.parent.children.create!(name: commodity.symbol,
                                        account_type: Account.asset_type,
                                        content_type: Account.commodity_content,
                                        entity: lot.account.entity)
  end

  def find_or_create_commodity_account
    lot.account.parent.children.where(name: commodity.symbol).first || create_commodity_account
  end
end
