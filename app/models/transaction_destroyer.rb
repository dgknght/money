# Manages the destruction of a transaction
# and and dependent models
class TransactionDestroyer

  attr_accessor :notice, :error

  def destroy
    return false unless valid?
    begin
      transacted_destroy
      self.notice = success_notice
      true
    rescue => e
      Rails.logger.error "Unable to destroy the transaction #{@transaction.inspect} #{e.inspect}"
      self.error = e.to_s
      false
    end
  end

  def initialize(transaction)
    @transaction = transaction
    @lot_changed = false
  end

  private

  def buy_transaction?
    !sell_transaction?
  end

  def has_associated_sell_transactions?
    @transaction.lot_transactions.any? do |lot_transaction|
      lot_transaction.lot.transactions.any?(&:sale?)
    end
  end

  def process_lot_transaction(lot_transaction)
    if lot_transaction.shares_traded > 0
      # reversing a buy transaction - only need to delete the lot
      lot_transaction.lot.destroy
    else
      # reversing a sell transaction - need to restore shares to the lot
      lot_transaction.lot.shares_owned -= lot_transaction.shares_traded
      lot_transaction.lot.save!
      lot_transaction.destroy
    end
    @lot_changed = true
  end

  def sell_transaction?
    @transaction.lot_transactions.any?(&:sale?)
  end

  def success_notice
    @lot_changed ? "The commodity transaction was removed successfully." : "The transaction was removed successfully."
  end

  def transacted_destroy
    Transaction.transaction do
      @transaction.destroy
      @transaction.lot_transactions.each { |lt| process_lot_transaction(lt) }
    end
  end

  def valid?
    if buy_transaction? && has_associated_sell_transactions?
      self.error = 'Cannot delete commodity purchase transactions with associated sale transactions.'
      return false
    end

    true
  end
end
