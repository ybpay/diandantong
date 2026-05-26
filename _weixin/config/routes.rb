Ddt::Core::Engine.add_routes do
  
  # 为了节省二维码的精度
  get '/MP_(:hash).txt' => 'common/weixin#wechat_server_auth_file', as: :wechat_server_auth_file1
  get '/mp/MP_(:hash).txt' => 'common/weixin#wechat_server_auth_file', as: :wechat_server_auth_file2
  get '/q/:id', to: 'common/qr_code_scenes#show', as: :qr_code
  namespace :common do
    post 'js_error_report' => 'js_error_report#create', as: :js_error_report
    post 'cloopen_call_resp' => 'cloopen_call_resp#create', as: :cloopen_call_resp
    post 'weixin_oauth_callback' => 'weixin#weixin_oauth_callback'
    get 'wechat_account_oauth_callback' => 'weixin#wechat_account_oauth_callback'
    resources :shops do
      get '/api' => 'messages#validate', as: :gh_config_api
      post '/api' => 'messages#create', as: :message_create_root
      resources :qr_code_scenes, only: [:show]
      resources :verify_vip_info_qr_code_scenes, only: [:show] do
        get :verify, on: :member
      end
      resource :verify_vip_info, only: [:show] do
        get :verify
      end
      resources :reporters, only: [:index] do
        get :show, on: :collection
      end
    end
    get 'clear_cookies' => 'clear_cookies#clear_cookies', as: :clear_cookies if Rails.env.development?
  end

  namespace :weixin do
    resources :shops do
      member do
        get 'main' => 'shops#show'
        get :my
        get :cart
        get :order
        get :queue
        get :manage
      end
      resources :bind_orders, only: [:show] do
        post :bind, on: :member
      end
      resources :recharge_products, only: [:index]
      resources :wechat_share_records do
        post :confirm, on: :member
      end
      resources :sharable_coupons do
        post :receive, on: :member
      end
      resources :censor_reports, only: [:create]
      resources :promotions
      resources :tuans, only: [:index, :show]
      resources :zones, only:[:index] do
        collection do
          get :get_zone_by_city
        end
      end
      resources :exchange_codes do
        member do
          get :get_permissions
          get :get_qrcode
          post :exchange
        end
      end
      scope :module => :order do
        resources :deliveryman_orders
      end
      resources :branches do
        get :filters, on: :collection
        resources :products
        resources :combos, only: [:index] do
          post :add_combo_package, on: :member
        end
        resources :comments
        resources :invoices, only: [] do
          post :create, on: :collection
        end
        resource :guest_queue do
          post :cancel
          post :bind_user
          get :get_by_qr_code
        end
        resources :combo_packages
        resources :categories
        resources :table_zones
        resources :tables, only: [:show] do
          member do
            post :open
          end

          collection do
            get :get_all
          end
          
          resources :order_itemables, only: [:index] do
            member do
              post :plus
              post :minus
            end
          end
        end
        resources :reservation_time_points
        scope :module => :cart do
          concern :cart do
            post :add_itemable
            post :remove_itemable
            post :clear
            post :update_cart
            post :patch, to: :update
            post :add_combo_package
          end
          concern :cart_coupon do
            post :apply_coupon
            post :clear_coupon
          end
          resource :delivery_cart,    concerns: [:cart, :cart_coupon] do
            post :update_shipment
          end
          resource :reservation_cart, concerns: :cart do
            post :update_reservation_info
          end
          resource :eat_in_hall_cart, concerns: [:cart, :cart_coupon] do
            post :update_table_info
            post :set_order_itemables_from_table
          end
          resource :fastfood_cart, concerns: [:cart, :cart_coupon]
          resource :groupon_cart,     concerns: :cart do
            post :add_tuan
          end
          resource :recharge_cart, concerns: :cart do
            post :add_recharge_product
          end
        end
        scope :module => :order do
          concern :order do
            member do
              get :prepare_pay_online
              get :get_pay_online
              post :cancel
              post :confirm
              post :complete
              post :append_itemables
              get :get_permissions
              get :avariable_coupons
              get :check_order_paid
            end
            get :association_domains, on: :collection
          end
          concern :order_coupon do
            member do
              post :apply_coupon
              post :clear_coupon
            end
          end
          resources :delivery_orders,    only: [:index, :create, :show], concerns: :order do
            member do
              post :hasten
              get :refresh_location
              get :ship
              post :start_shipment
              post :finish_shipment
              post :assign_to_self
            end
          end
          resources :reservation_orders, only: [:create, :show], concerns: :order
          resources :eat_in_hall_orders, only: [:create, :show], concerns: [:order, :order_coupon] do
            get :get_order_by_table, on: :collection
            member do
              post :hasten
              post :call_waiter
              post :request_pay
              post :update
            end

          end
          resources :fastfood_orders, only: [:create, :show], concerns: :order do
            post :hasten, on: :member
            post :call_waiter, on: :member
          end
          resources :groupon_orders, only: [:create, :show], concerns: :order do
          end
          resources :recharge_orders, only: [:create, :show], concerns: :order do
          end
          resources :payment_orders, only: [:create, :show], concerns: :order do
          end
          resources :orders do
            resource :order_comment
          end
          resources :invitation_orders, only: [:show] do
            member do
              post :agree
              post :disagree
            end
          end
        end
      end
      resources :articles, only: [:show]
      resource :vip_info_setting, only: [:show]
      scope :module => :user do
        scope :module => :order do
          resources :delivery_orders,    only: [:index]
          resources :reservation_orders, only: [:index]
          resources :eat_in_hall_orders, only: [:index]
          resources :fastfood_orders,    only: [:index]
          resources :groupon_orders,     only: [:index]
          resources :recharge_orders,    only: [:index]
          resources :payment_orders,     only: [:index]
        end
        resource :user, only: [] do
          post :authenticate_password
          post :update_location
          post :update_vip_info
          post :send_vip_info_phone_validation_code
          get  :scan_code
          post :apply_vip
          post :update_pay_password
          post :send_validation_code
          post :bind_vip
          get :is_correct_code
          get :show
          get :card_wallet_logs
          get :credits_wallet_logs
          resources :addresses, only: [:index, :show, :create] do
            member do
              post :set_default
              post :delete, to: "addresses#destroy"
              post :patch, to: "addresses#update"
            end
          end
          scope :module => :coupon do
            resources :coupon_versions, only: [:index, :show] do
              member do
                post :exchange
              end
            end
            resources :coupons,  only: [:index, :show] do
              get :status, on: :collection
            end
            resources :groupons, only: [:index, :show] do
              member do
                post :apply_refund
                post :cancel_apply_refund
              end
            end
            resources :vouchers, only: [:index, :show] do
              member do
                post :apply_refund
                post :cancel_apply_refund
              end
            end
          end
          resources :sharable_coupons
          resources :sign_records
          resources :favorite_branches, only: [:index, :show, :create] do
            member do
              post 'delete', to: "favorite_branches#destroy"
            end
          end
          resource :merchant_apply, only: [:show, :create] do
            member do
              post :cancel
            end
          end
        end
      end
    end
  end

  # API v1 Routes
  namespace :api do
    namespace :v1 do
      namespace :weixin do
        resources :shops, only: [:index, :show] do
          resources :branches, only: [] do
            resources :products, only: [:index, :show]
            resources :categories, only: [:index]
            resources :orders, only: [:index, :show, :create]
            resources :guest_queues, only: [:index, :show, :create]
            resources :vip_infos, only: [:index, :show]
          end
        end
      end
    end
  end
end
