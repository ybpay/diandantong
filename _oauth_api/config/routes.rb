Ddt::Core::Engine.add_routes do
  # hack for doorkeep in engine (from https://github.com/doorkeeper-gem/doorkeeper/issues/328#issuecomment-34019343)
  old_scope = @scope[:module]
  @scope[:module] = nil
  use_doorkeeper
  @scope[:module] = old_scope

  namespace :oauth_api do
    resource :account, only: [:show] do
    end
    resources :branches, only: [:index] do
      resources :products, only: [:index]
    end
  end

  # API v1 Routes (unified)
  namespace :api do
    namespace :v1 do
      namespace :oauth do
        resource :account, only: [:show]
        resources :branches, only: [:index] do
          resources :products, only: [:index]
        end
      end
    end
  end
end
