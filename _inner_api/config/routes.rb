Ddt::Core::Engine.add_routes do
  namespace :inner_api, defaults: {format: 'json'} do
    resources :shops
    resources :roles, only: [:index]
    resources :branches do 
      resources :products, only: [:index]
      resources :categories, only: [:index]
    end
    resources :agents
    resources :accounts do 
      post :authenticate, on: :collection
    end
    resources :register_forms
    resources :feature_module_groups
    resources :printers, only: [] do
      collection do
        post :notify_error
        post :notify_not_working
        post :batch_notify_not_working
      end
    end
  end

  # API v1 Routes (unified)
  namespace :api do
    namespace :v1 do
      namespace :inner do
        resources :shops, only: [:index, :show]
        resources :branches, only: [:index, :show] do
          resources :products, only: [:index]
        end
        resources :accounts, only: [:index, :show] do
          post :authenticate, on: :collection
        end
        resources :printers, only: [] do
          collection do
            post :notify_error
            post :notify_not_working
            post :batch_notify_not_working
          end
        end
      end
    end
  end
end