Ddt::Core::Engine.add_routes do
  namespace :webpos do
    devise_for :webpos_accounts, class_name: 'Ddt::Account', skip: [:password, :registration, :unlock], skip_helpers: true, controllers: {
      sessions: 'ddt/webpos/webpos_accounts/sessions'
    }
    get '/' => "home#index"
    get '/kitchen' => "home#kitchen"
    get '/users' => "home#users"
    get '/queue' => "home#queue"
    get '/bill' => "home#bill"
    get '/estimate' => "home#estimate"

    resource :account, only: [:show] do
      get :bosses_and_workers
      post :authorization
      get :get_authorizers
      get :permissions
    end
    namespace :extended_form do
      resources :shops do
        resources :orders
      end
    end
    resources :shops, only: [:show] do
      resource :ability, only: [:show]
      resources :vip_levels, only: [:index]
      resources :gift_reasons, only: [:index]
      resources :recharge_products, only: [:index]
      resources :temp_recharge_products, only: [:create]
      resources :vip_infos, only: [:index, :show, :create] do
        collection do
          get :get_by_scan_code
        end
        member do
          get :wallet_logs
          post :merge
          post :become
          post :reject
          post :update
        end
        resources :card_wallet_logs, only: [] do
          put :change_note, on: :member
        end
      end

      resources :addresses, only: [] do
        collection do
          get :search
        end
      end

      resources :reservation_infos, only: [] do
        collection do
          get :search
        end
      end

      resource :private_pub, only: [] do
        get :load_config
      end

      resource :qr_code, only: [] do
        get :verify_vip_info
        get :reload_verify_qrcode
      end

      resources :statistics, only: [] do
        collection do
          get :product_sales
          get :order_quantity
        end
      end

      resources :user_card_wallets, only: [] do
        member do
          post :recharge
          post :exchange
        end
      end

      resources :user_credits_wallets, only: [] do
        member do
          post :exchange
          post :get
        end
      end

      resources :branches, only: [:show, :index] do
        member do
          post :open_shift
          post :close_shift
          get :get_shift
          post :print_shift
          get :waiter_names
          post :sdu_upload_orders
          post :sdu_query_orders
          get :cache_versions
        end
        resource :bill_center, only: [] do
          get :discount_list
          get :waiter_list
          get :gift_item_list
          get :subtract_item_list
          get :sale_list
          get :payment_list
          get :shift_list
          get :combo_package_list
          get :anti_settlement_list
          get :order_cancel_list
          get :queue_list
          get :by_weight_product_list
        end
        resources :discount_plans,  only: [:index]
        resources :item_notes,  only: [:index]
        resources :tick_accounts,  only: [:index]
        resources :delivery_mans,  only: [:index]
        resources :delivery_zones, only: [:index]
        resources :delivery_dates, only: [:index]
        resources :form_elements, only: [:index]
        resources :printers, only: [:index] do
          post :reprint, on: :collection
          get :get_states, on: :collection
          post :test_print_all, on: :collection
          post :test_print, on: :collection
        end
        resources :litps, only: [:index] do
          member do
            put :confirm
            put :complete
          end
          collection do
            get :cooks
            get :counts
          end
        end
        resources :table_zones, only: [:index] do
          collection do
            get :with_reservation_time_points
          end
        end
        resources :table_zones, only: [:index]
        resources :tables, only: [:show, :index] do
          collection do
            get :get_changed_tables
            get :get_reservation_tables
          end
          member do
            post :open
            post :clear
            post :check_out
            post :cancel_check_out
            post :update_guest_num
            post :bind_table
            post :unbind_table
            post :force_clear
            get :get_consume_bill
          end
        end
        resources :categories, only: [:index, :show]
        resources :products, only: [:index]
        resources :combos, only: [:index] do
          post :add_combo_package, on: :member
        end
        resources :variant_packages, only: [:create, :update]

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
              post :privilege_discount
              post :privilege_reduction
              post :privilege_free
              post :moling
              post :cancel_privilege_discount
              post :cancel_privilege_reduction
              post :cancel_privilege_free
              post :cancel_moling
              post :apply_coupon
              post :rollback_coupon
              post :apply_voucher
              post :rollback_voucher
              get :bill
              post :create_pay_items
              post :pay_all_pay_items
              post :clear_pay_items
              post :hasten
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
              post :bind_reservation_order
              post :anti_settlement
              post :trace_waiter
              post :allow_selfpay
              post :update_guest_num
              post :change_weight
            end
          end
          resources :fastfood_orders, only: [:create, :show], concerns: :order do
            member do
              get :call_customer
              post :anti_settlement
            end
          end
          resources :reservation_orders, only: [:show, :create], concerns: :order do
            member do
              post :change_to_eat_in_hall
              post :bind_table
              post :edit_reservation_info
            end
          end
          resources :delivery_orders, only: [:show, :create], concerns: :order do
            member do
              post :assign_delivery_man
              post :append
              get :active_line_items
              post :subtract
            end
          end
          resources :groupon_orders, only: [:show], concerns: :order
          resources :payment_orders, only: [:show, :create], concerns: :order
          resources :recharge_orders, only: [:show, :create], concerns: :order do
            member do
              post :init_refund
            end
          end
          resources :orders, only: [:index, :show] do
            collection do
              get :pending_counts
              post :batch_change_state
            end
            resources :pay_items do
              member do
                post :paid
                post :get_pay_online
                post :pay_by_seller_scan
                post :refund
                post :close
              end
            end
            resources :line_items do
              member do
                post :change_price
              end
            end
          end
        end
        resources :queue_settings, only: [:index] do
          collection do
            get :history
            get :queue_states
            post :create_guest_queue
          end
          member do
            post :set_notify_number_in_advance
          end
          resources :guest_queues, only: [:create, :index, :show] do
            member do
              post :pass
              post :cancel
              post :requeue
              post :accept
              post :notify
              post :reprint
              post :print_pre_order
              get :pre_order_bill
              get :bill
            end
          end
        end

        scope :module => :coupon do
          resources :coupons, only: [] do
            collection do
              get :search
              get :available
              post :find_by_code
              post :exchange_by_code
            end
            post :apply
          end
          resources :groupons, only: [] do
            collection do
              get :available
              post :find_by_code
              post :exchange_by_code
            end
            post :exchange_by_id
          end
          resources :vouchers, only: [] do
            collection do
              get :search
              get :available
              post :find_by_code
              post :exchange_by_code
            end
            post :exchange_by_id
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
        resources :time_intervals, only: [:index]
      end

    end
  end

  # API v1 Routes
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
