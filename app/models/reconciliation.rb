class Reconciliation < ActiveRecord::Base
  belongs_to :account
  validates_presence_of :account_id, :reconciliation_date, :closing_balance
  
  default_scope { order(:reconciliation_date) }
  
  def previous_balance
    previous = account.reconciliations.where('reconciliation_date < ?', reconciliation_date).last
    previous.nil? ? 0 : previous.closing_balance
  end
end
