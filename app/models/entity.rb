# == Schema Information
#
# Table name: entities
#
#  id                             :integer          not null, primary key
#  user_id                        :integer          not null
#  name                           :string(100)      not null
#  created_at                     :datetime
#  updated_at                     :datetime
#  suspend_balance_recalculations :boolean          default(FALSE), not null
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
    recalculate_all_account_balances
  end

  def fast_destroy!
    statements = [
      "DELETE FROM budget_item_periods WHERE budget_item_id in (SELECT bi.id FROM budget_items bi INNER JOIN budgets b ON b.id = bi.budget_id WHERE b.entity_id = #{id})",
      "DELETE FROM budget_items WHERE budget_id in (SELECT id FROM budgets WHERE entity_id = #{id})",
      "DELETE FROM budgets WHERE entity_id = #{id}",
      "DELETE FROM attachment_contents WHERE entity_id = #{id}",
      "DELETE FROM budget_monitors WHERE entity_id = #{id}",
      "DELETE FROM reconciliation_items WHERE reconciliation_id in (SELECT r.id FROM reconciliations r INNER JOIN accounts a ON a.id = r.account_id WHERE a.entity_id = #{id})",
      "DELETE FROM reconciliations WHERE account_id IN (SELECT id FROM accounts WHERE entity_id = #{id})",
      "DELETE FROM transaction_items WHERE account_id IN (SELECT id FROM accounts WHERE entity_id = #{id})",
      "DELETE FROM lot_transactions WHERE transaction_id IN (SELECT id FROM transactions WHERE entity_id = #{id})",
      "DELETE FROM lots WHERE account_id IN (SELECT id FROM accounts WHERE entity_id = #{id})",
      "DELETE FROM accounts WHERE entity_id = #{id}",
      "DELETE FROM attachments WHERE transaction_id IN (SELECT id FROM transactions WHERE entity_id = #{id})",
      "DELETE FROM transactions WHERE entity_id = #{id}",
      "DELETE FROM prices WHERE commodity_id in (SELECT id FROM commodities WHERE entity_id = #{id})",
      "DELETE FROM commodities WHERE entity_id = #{id}"
    ]
    statements.each do |s|
      Entity.connection.execute(s)
    end
    destroy!
  end

  def recalculate_all_account_balances
    Rails.logger.info "recalculating balances for entity #{name}"
    child_first_account_list.each do |a|
      a.recalculate_balance!(rebuild_item_indexes: true)
      a.recalculate_value
      a.recalculate_cost
      a.recalculate_gains
      a.recalculate_children_balance
      a.recalculate_children_value
      a.recalculate_children_cost
      a.recalculate_children_gains
      a.save!
      Rails.logger.info "recalculated balances for #{a.path} value=#{a.value} children_value=#{a.children_value}"
    end
    Rails.logger.info "recalculation complete"
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

  def child_first_account_list(account = nil, list = [])
    x = account ? account.children : accounts.root
    x.reduce(list) do |l, account|
      child_first_account_list account, l
      l << account
    end
  end
end
