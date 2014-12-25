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
      primary.item :reports, 'Reports', reports_entity_path(current_entity)
      primary.item :sign_out, 'Sign out', destroy_user_session_path, method: :delete
    else
      primary.item :sign_in, 'Sign in', new_user_session_path
    end
  end
end
