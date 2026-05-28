Ddt::Core::Engine.add_routes do
  # API v1 Agent Routes — Vue 3 Agent SPA
  namespace :api do
    namespace :v1 do
      namespace :agent do
        # Authentication
        post "auth/login", to: "agentsys/sessions#create"
        delete "auth/logout", to: "agentsys/sessions#destroy"

        # Current agent info
        get "user", to: "agentsys/current_agent#show"

        # Dashboard
        get "dashboard", to: "agentsys/dashboard#index"

        # Merchants (shops)
        resources :merchants, controller: "agentsys/merchants" do
          member do
            post :renew
            put :suspend
            put :activate
            post :reset_password
          end
          collection do
            get :expirations, to: "agentsys/expirations#index"
          end
        end

        # Brands
        resources :brands, controller: "agentsys/brands"

        # OEM Settings
        resource :oem_settings, controller: "agentsys/oem_settings", only: [:show, :update]

        # Sub-agents
        resources :agents, controller: "agentsys/sub_agents"

        # Statistics
        get "statistics", to: "agentsys/statistics#index"

        # Settings
        get "settings", to: "agentsys/settings#show"
        put "settings/profile", to: "agentsys/settings#update_profile"
        put "settings/password", to: "agentsys/settings#update_password"
        put "settings/notifications", to: "agentsys/settings#update_notifications"

        # Plans
        get "plans", to: "agentsys/plans#index"

        # Recharge records
        resources :recharge_records, controller: "agentsys/recharge_records", only: [:index, :show, :create]

        # Feature modules configs
        get "feature_modules_configs", to: "agentsys/feature_modules_configs#index"
        get "feature_modules_configs/price", to: "agentsys/feature_modules_configs#price"
      end
    end
  end
end
