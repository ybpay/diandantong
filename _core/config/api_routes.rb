Ddt::Core::Engine.add_routes do
  # API v1 - Core endpoints
  namespace :api do
    namespace :v1 do
      resource :auth, only: [] do
        post :login
        get :me
      end
      resources :accounts, only: [:show, :update]
      resources :shops, only: [:index, :show] do
        resources :branches, only: [:index, :show, :update]
      end
    end
  end
end
