# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.selected_class = 'active'
    primary.dom_class = 'nav nav-pills'
    if user_signed_in?
      primary.item :accounts, 'Accounts', app_path
      primary.item :commodities, 'Commodities', entity_commodities_path(current_entity)
      primary.item :budgets, 'Budgets', entity_budgets_path(current_entity)
      primary.item :budget_monitors, 'Budget monitors', entity_budget_monitors_path(current_entity)
      primary.item :reports, 'Reports', reports_entity_path(current_entity)
      primary.item :import, 'Import', import_entity_path(current_entity) do |import|
        import.item :import_accounts, 'Import accounts', new_import_entity_accounts_path(current_entity)
        import.item :import_transaction, 'Import transactions', new_import_entity_transactions_path(current_entity)
        import.item :import_gnucash, 'Import from GnuCash', new_gnucash_entity_path(current_entity)
      end
      primary.item :sign_out, 'Sign out', destroy_user_session_path, method: :delete
    else
      primary.item :sign_in, 'Sign in', new_user_session_path
    end
  end
end
