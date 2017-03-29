Ddt::Core::Engine.add_routes do
  namespace :agentsys do

    devise_for :agents, class_name: 'Ddt::Agent', controllers: {
      sessions: "ddt/agentsys/agents/sessions",
      registrations: 'ddt/agentsys/agents/registrations',
      passwords: 'ddt/agentsys/agents/passwords'
    }

    root to: 'shops#index'
    resources :shops do
      member do
        post 'follow'
        post 'give_up'
      end
    end

    resources :feature_modules_configs, only: [:index] do 
      collection do 
        get :index_group
        get :price_of_charge_version
      end
    end
    resources :agent_printers do
      collection do
        get :get_purchase
        post :post_purchase
      end
    end
    resources :accounts
    resources :agent_materials
    resources :users, only: [:index]

    resources :shop_recharge_records do 
      collection do 
        get :new_free
        post :create_free
      end
    end

    get 'profile', to: 'agents#profile'
    get :edit_profile, to: 'agents#edit_profile'
    match 'update_profile', to: 'agents#update_profile', via: [:put, :patch]
  end
end
