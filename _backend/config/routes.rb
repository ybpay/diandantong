#encoding: utf-8
require 'sidekiq/web'
Ddt::Core::Engine.add_routes do

  mount ChinaCity::Engine => '/china_city'

  # Devise authentication routes
  get '/account/sign_up' => 'backend/register_forms#new'
  devise_for :account, class_name: 'Ddt::Account', controllers: {
    sessions:      'ddt/backend/account/sessions' ,
    confirmations: 'ddt/backend/account/confirmations' ,
    registrations: 'ddt/backend/account/registrations' ,
    passwords:     'ddt/backend/account/passwords' ,
    unlocks:       'ddt/backend/account/unlocks' }

  devise_scope :account do
    get '/' => 'backend/account/sessions#new', as: :root
  end

  post 'system_alipays_notify/:service_product_order_id', to: "system_alipays#system_alipay_notify", as: :system_alipay_notify
  get '/protocol', to: "protocols#index"

  # Legacy image path redirect
  get '/images/defaults/:name', to: redirect { |path_params, req|
    full_name = path_params[:name] + (path_params[:format].present? ? '.' + path_params[:format] : '');
    asset_host = Rails.application.config.action_controller.asset_host
    base = ActionController::Base.helpers.asset_url("ddt/images/#{full_name}")
    if asset_host.present? && base.present? && base.start_with?(?/)
      asset_host + base
    else
      base
    end
  }

  # Sidekiq admin dashboard
  authenticate :account, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web, at: '/sidekiq', as: :sidekiq_web
  end

  # API v1 Routes (Vue 3 Admin frontend)
  namespace :api do
    namespace :v1 do
      namespace :backend do
        resources :shops, only: [:show, :update], param: :shop_slug do
          member do
            get :feature_modules
            get :branches_summary
          end
          resources :branches, only: [:index, :show, :create, :update] do
            resources :products, only: [:index, :show, :create, :update, :destroy] do
              collection do
                get :search
                post :batch_on_shelf
                post :batch_off_shelf
                post :batch_remove
              end
            end
            resources :categories, only: [:index, :show, :create, :update, :destroy]
            resources :orders, only: [:index, :show, :update] do
              collection do
                post :batch_change_state
              end
              member do
                put :confirm
                put :cancel
                put :complete
                put :refund
              end
            end
            namespace :order do
              resources :delivery_orders, only: [:index, :show] do
                collection do
                  get :assigned
                end
                member do
                  put :confirm
                  put :cancel
                  put :complete
                  put :assign
                  put :start
                  put :ship
                end
              end
              resources :eat_in_hall_orders, only: [:index, :show] do
                member do
                  put :confirm
                  put :cancel
                  put :complete
                end
              end
              resources :fastfood_orders, only: [:index, :show] do
                member do
                  put :confirm
                  put :cancel
                  put :complete
                end
              end
              resources :groupon_orders, only: [:index, :show] do
                member do
                  put :confirm
                  put :cancel
                  put :complete
                end
              end
              resources :reservation_orders, only: [:index, :show] do
                member do
                  put :confirm
                  put :cancel
                  put :complete
                end
              end
              resources :recharge_orders, only: [:index, :show] do
                member do
                  put :confirm
                  put :cancel
                  put :complete
                end
              end
              resources :payment_orders, only: [:index, :show] do
                member do
                  put :confirm
                  put :cancel
                  put :complete
                end
              end
            end
            resources :printers, only: [:index, :show, :create, :update, :destroy]
            namespace :crm do
              resources :vip_infos, only: [:index, :show, :create, :update]
            end
            namespace :statistics do
              get :business
              get :orders
              get :products
              get :finance
            end
            namespace :store do
              resources :tables, only: [:index, :show, :create, :update, :destroy] do
                member do
                  get :current_order
                  put :enable_qr_code
                  put :disable_qr_code
                  put :regenerate_qr_code
                end
                collection do
                  post :batch_create
                end
              end
              resources :table_zones, only: [:index, :show, :create, :update, :destroy]
              resources :queue_settings, only: [:index, :show, :create, :update, :destroy]
              resource :kitchen_setting, only: [:show, :update]
            end
            namespace :marketing do
              resources :discount_plans, only: [:index, :show, :create, :update, :destroy]
            end
          end
          namespace :payment do
            resources :payments, only: [:index, :show] do
              member do
                post :refund
              end
              collection do
                get :statistics
              end
            end
          end
          namespace :user do
            resources :base_users, only: [:index, :show, :update] do
              collection do
                get :normal_users
                get :vip_users
              end
              member do
                get :wallet_logs
                get :recharge_orders
              end
            end
          end
          resources :coupons, only: [:index, :show, :create, :update, :destroy]
          namespace :marketing do
            resources :vouchers, only: [:index, :show] do
              member do
                post :refund
              end
            end
            resources :groupons, only: [:index, :show] do
              member do
                post :refund
              end
            end
            resources :coupon_versions, only: [:index, :show, :create, :update, :destroy]
          end
          namespace :crm do
            resources :vip_levels, only: [:index, :show, :create, :update, :destroy]
            resources :recharge_products, only: [:index, :show, :create, :update, :destroy] do
              member do
                put :change_position
              end
            end
            resource :credits_setting, only: [:show, :update]
          end
          namespace :system do
            resources :roles, only: [:index, :show, :create, :update, :destroy]
            resources :printers, only: [:index, :show]
            resources :notification_settings, only: [:show, :update], param: :account_id
          end
        end
      end
    end

    # Admin API v1 — clean URL namespace for Vue 3 Admin frontend
    namespace :admin do
      namespace :v1 do
        # Marketing
        resources :vouchers, only: [:index, :show] do
          member { post :refund }
        end
        resources :groupons, only: [:index, :show] do
          member { post :refund }
        end
        resources :coupon_versions, only: [:index, :show, :create, :update, :destroy]
        resources :coupons, only: [:index, :show, :create, :update, :destroy]
        resources :promotions, only: [:index, :show, :create, :update, :destroy]
        # CRM / Members
        resources :vip_levels, only: [:index, :show, :create, :update, :destroy]
        resources :recharge_products, only: [:index, :show, :create, :update, :destroy]
        resource :credits_setting, only: [:show, :update]
        resources :vip_infos, only: [:index, :show, :create, :update]
        # Store
        resources :table_zones, only: [:index, :show, :create, :update, :destroy]
        resources :tables, only: [:index, :show, :create, :update, :destroy]
        resources :queue_settings, only: [:index, :show, :create, :update, :destroy]
        resource :kitchen_setting, only: [:show, :update]
        resource :discount_plan, only: [:show, :create, :update, :destroy]
        # System
        resources :roles, only: [:index, :show, :create, :update, :destroy]
        resources :printers, only: [:index, :show, :create, :update, :destroy]
        resources :accounts, only: [:index, :show, :create, :update, :destroy]
        resource :notification_setting, only: [:show, :update]
        # Statistics
        namespace :statistics do
          get :business
          get :orders
          get :products
          get :finance
          get :coupons
          get :workers
        end
        # Shop
        resource :shop, only: [:show, :update]
        resources :branches, only: [:index, :show, :create, :update]
        resources :products, only: [:index, :show, :create, :update, :destroy]
        resources :categories, only: [:index, :show, :create, :update, :destroy]
        resources :orders, only: [:index, :show, :update] do
          member do
            put :confirm
            put :cancel
            put :complete
          end
        end
        resources :delivery_orders, only: [:index, :show] do
          member do
            put :assign
            put :start
            put :ship
          end
        end
        resources :payments, only: [:index, :show]
      end
    end
  end
end
