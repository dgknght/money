# Manages the destruction of a transaction
# and and dependent models
class TransactionDestroyer

  def destroy
    @transaction.destroy
    @transaction.lot_transactions.each { |lt| process_lot_transaction(lt) }
  end

  def initialize(transaction)
    @transaction = transaction
  end

  private

  def process_lot_transaction(lot_transaction)
    if lot_transaction.shares_traded > 0
      lot_transaction.lot.destroy
    else
    end
  end
end
