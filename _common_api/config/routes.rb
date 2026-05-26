Ddt::Core::Engine.add_routes do
  namespace :common_api, defaults: {format: 'json'} do
    namespace :v1 do
      resource :shop, only: [:show]
      resource :account, only: [:show] do
        post :login
        post :logout
        post :auth
        post :update_channel
        post :send_sms_captcha
        post :register
        post :report_location
        get  :permissions
      end

      # shop级
      resources :accounts, only: [:index, :update, :create, :destroy] do
        member do
          post :update
        end
      end

      resources :roles, only: [:index]

      resources :notifications do
        collection do
          get :pull
        end
      end

      resources :vip_infos, only: [] do
        collection do
          get :get_by_scan_code
        end

        resources :credits_wallets, only: [] do
          collection do
            post :exchange
            post :recharge
          end
        end
      end

      resource :notification_receive_setting, only: [:show, :update] do
          post :update
      end

      resources :labels, only: [] do
        collection do
          get :subtract
          get :gift
          get :service
        end
      end

      resources :statistics, only: [:index] do
        get :result, on: :collection
        get :last_shift, on: :collection
      end
      resources :graph_statistics, only: [] do
        collection do
          get :product_sale
          get :product_category_sale
          get :business
          get :order_track_from
          get :user_source
          get :vip_amount
          get :suspicious_order
        end
      end

      resources :printers, only: [] do
        post :notify_error, on: :collection
      end

      resources :branches, only: [:show, :index, :update] do
        # branch级
        member do
          post :open_shift
          post :close_shift
          get :get_shift
          get :cache_versions
          post :update
          post :update_cs_data
        end
        resources :printers, only: [:index, :show, :update, :create] do
          post :reprint, on: :collection
          post :test_print, on: :collection
          post :update, on: :member
        end

        resources :products ,only: [:index, :update] do
          post :update, on: :member
        end
        resources :categories , only: [:index]
        resources :discount_plans, only: [:index]
        resources :combos, only: [:index, :show, :update] do
          post :update, on: :member
          post :add_combo_package, on: :member
        end

        resources :table_zones, only: [:index] do
          get :with_tables
          get :with_reservation_time_points
        end

        resources :tables, only: [:index, :show] do
          collection do
            get :search
          end
          member do
            post :open
            post :clear
            post :check_out
            post :cancel_check_out
          end
        end

        resources :variant_packages do
          post :create
          put :update
        end

        resources :queue_settings, only: [:index]
        resources :guest_queues, only: [:index, :create, :show] do
          member do
            post :pass
            post :cancel
            post :requeue
            post :accept
            post :notify
            post :reprint
            post :print_pre_order
          end
        end

        resources :item_notes, only: [:index]

        resources :base_coupons, only: [] do
          get :find_by_code, on: :collection
          post :exchange, on: :member
        end

        scope :module => :order do
          concern :order do
            member do
              post :confirm
              post :complete
              post :cancel
              post :change_vip_info
              post :unbind_vip_info
              post :credits_deduction
              post :cancel_credits_deduction
              post :card_deduction
              post :hasten
              post :reprint
              post :moling
              post :cancel_moling
              get :bill
              post :apply_coupon
              post :rollback_coupon
              post :apply_voucher
              post :rollback_voucher
              post :privilege_discount
              post :privilege_reduction
              post :privilege_free
              post :cancel_privilege_discount
              post :cancel_privilege_reduction
              post :cancel_privilege_free
              post :add_discount_plan
              post :cancel_discount_plan
              post :add_disabled_promotion
              post :remove_disabled_promotion
            end
          end

          resources :eat_in_hall_orders, only: [:show, :create], concerns: :order  do
            member do
              post :change_table
              post :merge_table
              post :move_itemable
              post :append
              get :active_line_items
              post :subtract
              post :call_waiter
              post :update_guest_num
              post :request_pay
              get :bill
            end
          end

          resources :fastfood_orders, only: [:create, :show], concerns: :order do
            post :create_and_pay, on: :collection
          end

          resources :delivery_orders, only: [:show], concerns: :order do
            member do
              post :append
              get :active_line_items
              post :subtract
              post :assign_delivery_man
              post :finish_delivery
              post :start_delivery
            end
          end

          resources :reservation_orders, only: [:show], concerns: :order do
          end
          resources :groupon_orders, only: [:show], concerns: :order
          resources :payment_orders, only: [:show, :create], concerns: :order
          resources :orders, only: [:index, :show] do
            resources :pay_items, only: [:show, :create] do
              collection do
                post :create_and_pay
                post :clear
                post :paid_all
              end
              member do
                post :paid
                post :get_pay_online
                post :pay_by_seller_scan
              end
            end
          end

        end

        resources :estimate_clear, only: [:index], controller: :estimate_clear do
          collection do
            post :add
            post :remove
            post :add_reciprocal
            post :remove_reciprocal
            post :clear
          end
        end

        resources :tick_accounts, only: [:index]
      end

      resources :payments, only: [] do
        collection do
          get :notify
          post :notify
        end
      end
    end
  end

  # http://[host]:[port]/oapi/v1/payments/[payment_id]/notify
  get 'oapi/v1/payments/:id/notify', to: 'common_api/v1/payments#notify'
  post 'oapi/v1/payments/:id/notify', to: 'common_api/v1/payments#notify'

  # API v1 Routes (unified)
  namespace :api do
    namespace :v1 do
      namespace :common do
        resource :session, only: [:create, :destroy]
        resource :account, only: [:show, :create] do
          post :update_password, on: :member
        end
        resources :shops, only: [:show], param: :shop_slug do
          resources :branches, only: [] do
            resources :products, only: [:index, :show]
            resources :categories, only: [:index]
            resources :orders, only: [:index, :show, :create, :update]
            resources :printers, only: [:index]
            resources :tables, only: [:index]
          end
        end
      end
    end
  end
end
