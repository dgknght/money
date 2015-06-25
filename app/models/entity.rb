# == Schema Information
#
# Table name: entities
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  name       :string(100)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Entity < ActiveRecord::Base
  validates_presence_of :name, :user_id
  
  belongs_to :user, inverse_of: :entities
  has_many :accounts, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :budget_monitors, dependent: :destroy
  has_many :commodities, dependent: :destroy
  has_many :attachment_contents, dependent: :destroy

  # This attribute is here to support the rails form_for helper
  # method in views/entities/new.html.haml. It can be removed
  # if a better workaround is found
  attr_accessor :data

  def current_budget
    today = Date.today
    budgets.where(['start_date <= ?', today]).select{|b| b.end_date > today}.first
  end

  def defer_balance_recalculations
    update_attribute :suspend_balance_recalculations, true
    yield
  ensure
    update_attribute :suspend_balance_recalculations, false
    leaf_accounts.each{|a| a.recalculate_balances!}
  end

  def fast_destroy!
    statements = [
      "DELETE FROM budget_item_periods USING budget_items, budgets WHERE budgets.id = budget_items.budget_id AND budget_items.id = budget_item_periods.budget_item_id AND budgets.entity_id = #{id}",
      "DELETE FROM budget_items USING budgets WHERE budgets.id = budget_items.budget_id AND budgets.entity_id = #{id}",
      "DELETE FROM budgets WHERE entity_id = #{id}",
      "DELETE FROM attachment_contents WHERE entity_id = #{id}",
      "DELETE FROM budget_monitors WHERE entity_id = #{id}",
      "DELETE FROM reconciliation_items USING reconciliations, accounts WHERE accounts.id = reconciliations.account_id AND reconciliations.id = reconciliation_items.reconciliation_id AND accounts.entity_id = #{id}",
      "DELETE FROM reconciliations USING accounts WHERE accounts.id = reconciliations.account_id AND accounts.entity_id = #{id}",
      "DELETE FROM transaction_items USING accounts WHERE accounts.id = transaction_items.account_id AND accounts.entity_id = #{id}",
      "DELETE FROM lot_transactions USING accounts, lots WHERE accounts.id = lots.account_id AND lots.id = lot_transactions.lot_id AND accounts.entity_id = #{id}",
      "DELETE FROM lots USING accounts WHERE accounts.id = lots.account_id AND accounts.entity_id = #{id}",
      "DELETE FROM accounts WHERE entity_id = #{id}",
      "DELETE FROM attachments USING transactions WHERE transactions.id = attachments.transaction_id AND transactions.entity_id = #{id}",
      "DELETE FROM transactions WHERE entity_id = #{id}",
      "DELETE FROM prices USING commodities WHERE commodities.id = prices.commodity_id AND commodities.entity_id = #{id}",
      "DELETE FROM commodities WHERE entity_id = #{id}",
      "DELETE FROM entities WHERE id=#{id}"
    ]
    statements.each do |s|
      Entity.connection.execute(s)
    end
  end

  # Returns the unrealized gains in the commodities held by the entity
  # as of the specified date
  def unrealized_gains
    accounts.commodities.reduce(0) {|sum, account| sum + account.gains_with_children}
  end

  def unrealized_gains_as_of(date)
    accounts.commodities.reduce(0) {|sum, account| sum + account.gains_with_children_as_of(date)}
  end

  private

  def leaf_accounts
    accounts.reject{|a| a.children.any?}
  end
end
