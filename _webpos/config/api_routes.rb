Ddt::Core::Engine.add_routes do
  namespace :api do
    namespace :v1 do
      namespace :webpos do
        resources :shops, only: [:show], param: :shop_slug do
          resources :branches, only: [] do
            resources :products, only: [:index, :show, :create, :update, :destroy]
            resources :categories, only: [:index, :show]
            resources :orders, only: [:index, :show, :update] do
              collection do
                get :pending_counts
                post :batch_change_state
              end
              resources :payments, only: [:create]
            end
            resources :vip_infos, only: [:index, :show, :create]
            resources :printers, only: [:index, :show, :create, :update, :destroy]
            resources :tables, only: [:index, :show]
            resource :shift, only: [] do
              get :current
              post :open
              patch "close/:id", action: :close, on: :collection
            end
            resource :statistics, only: [:index]
          end
        end
      end
    end
  end
end
