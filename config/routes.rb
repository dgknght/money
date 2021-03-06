Money::Application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users

  resources :entities do
    collection do
      post :gnucash
    end
    resources :accounts, only: [:new, :create, :index]
    resources :transactions, only: [:index, :new, :create]
    resources :commodities, only: [:index, :new, :create]
    resources :budgets, only: [:index, :new, :create]
    resources :budget_monitors, only: [:index, :new, :create]
    resources :prices, only: [] do
      collection do
        patch :download
      end
    end
    member do
      get :reports, to: 'reports#index'
      get :balance_sheet, to: 'reports#balance_sheet'
      get :income_statement, to: 'reports#income_statement'
      get :budget, to: 'reports#budget'
      get :import
    end
  end
  resources :accounts, only: [:show, :edit, :update, :destroy] do
    resources :reconciliations, only: [:new, :create]
    resources :transactions, only: [:index, :create]
    resources :transaction_items, only: [ :index, :create, :new ]
    resources :lots, only: [ :index ]
    member do
      get :new_commodity_transaction
      post :create_commodity_transaction
      get :holdings
      get :children
    end
  end
  resources :lots, only: [] do
    member do
      get :new_transfer
      put :transfer
      get :new_exchange
      put :exchange
    end
  end
  resources :transactions, only: [:show, :edit, :update, :destroy] do
    resources :attachments, only: [:index, :new, :create]
  end
  resources :commodities, only: [:show, :edit, :update, :destroy] do
    resources :prices, only: [:index, :new, :create]
    member do
      get :new_split
      put :split
    end
  end
  resources :prices, only: [:show, :edit, :update, :destroy]
  resources :attachments, only: [:show, :destroy]
  resources :attachment_contents, only: :show
  resources :transaction_items, only: [ :destroy, :edit, :update ]
  resources :budgets, only: [:show, :edit, :update, :destroy] do
    resources :budget_items, only: [:index, :new, :create], path: 'items'
  end
  resources :budget_items, only: [:show, :edit, :update, :destroy]
  resources :reconciliations, only: [:show]
  
  get 'home' => 'entities#index'
  get 'app' => 'pages#app'
  
  root :to => 'pages#welcome'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
