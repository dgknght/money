# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.selected_class = 'active'
    primary.dom_class = 'nav navbar-nav'
    if user_signed_in?
      primary.item :home, 'Home', home_path
      primary.item :app, 'Ajax', app_path
      primary.item :entities, 'Entities', entities_path
      if current_entity
        primary.item :accounts, 'Accounts', entity_accounts_path(current_entity)
        primary.item :transactions, 'Transactions', entity_transactions_path(current_entity)
        primary.item :commodities, 'Commodities', entity_commodities_path(current_entity)
        primary.item :budgets, 'Budgets', entity_budgets_path(current_entity)
        primary.item :budget_monitors, 'Budget monitors', entity_budget_monitors_path(current_entity)
        primary.item :reports, 'Reports', reports_entity_path(current_entity)
      end
      primary.item :sign_out, 'Sign out', destroy_user_session_path, method: :delete
    else
      primary.item :sign_in, 'Sign in', new_user_session_path
    end
  end
end
