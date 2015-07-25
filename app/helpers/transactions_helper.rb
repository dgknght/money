module TransactionsHelper
  def available_accounts_options(entity, selected_id)
    grouped_options_for_select(
      AccountListPresenter.new(entity).grouped_accounts,
      selected_id)
  end
end
