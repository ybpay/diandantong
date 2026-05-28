#encoding: utf-8
require 'sidekiq/web'
Ddt::Core::Engine.add_routes do


  mount ChinaCity::Engine => '/china_city'
  mount Ckeditor::Engine => '/ckeditor'
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

  # 遗留路径处理
  get '/images/defaults/:name', to: redirect { |path_params, req|
    full_name = path_params[:name] + (path_params[:format].present? ? '.' + path_params[:format] : '');
    # ActionController::Base.helpers.asset_url("ddt/images/#{full_name}")
    asset_host = Rails.application.config.action_controller.asset_host
    base = ActionController::Base.helpers.asset_url("ddt/images/#{full_name}")
    if asset_host.present? && base.present? && base.start_with?(?/)
      asset_host + base
    else
      base
    end
  }

  namespace :backend do
    resource :register_form do
      member do
        get :complete
      end
      collection do
        get :check_sms_captcha
        post :send_sms_captcha
      end
    end
    scope :module => :admin do
      resources :api_keys
      resources :sms_captchas, only: [:index, :destroy]
      resources :short_messages
      resources :js_errors
      resources :register_forms, only: [:index]
      resources :app_versions
      resources :jokes
      resources :qr_code_scenes do
        collection do
          get 'batch_new'
          post 'batch_create'
        end
      end
      resources :qr_code_assign_logs

      resources :variant_images do
        put :batch_set, on: :collection
      end
      resources :combo_images do
        put :batch_set, on: :collection
      end
      resources :asset_tags
      resources :pre_sale_staffs
      resources :sale_employees do
        member do
          get :statistic
        end
      end
      resources :admin_statistics do
        collection do
          get :visit_data
          get :order_data
          get :order_types
          get :order_origins
          get :pay_types
          get :queue_origins
          get :notification_data
          get :shop_data
        end
      end
      resources :censor_reports do
        member do
          put :confirm
          put :reject
          put :ban
          put :cancel_ban
        end
      end
      resources :withdraws, only: [:index] do
        member do
          put :complete
          put :cancel
        end
      end
      resources :shop_recharge_records, only: [:index, :show]
      resources :cs_branch_bindings, only: [:index, :show, :create]
      resources :sales_emails, only: [:index, :new, :create, :destroy]
      resources :agents do
        member do
          get 'reset_password'
        end
      end
      resources :agent_zones do
        resources :agent_rels
      end
      resources :lisences
      resources :agent_materials

      resources :service_products do
        collection do
          match 'change_position', via: [:patch, :put]
          get 'change_preferences'
        end
      end
    end

    concern :change_position do
      put :change_position, on: :member
    end

    resources :service_product_orders
    # get '/export_accounts' => "shops#export_accounts", as: :export_accounts
    resources :shops do
      member do
        get :crm
        get :config_guide
        get :welcome
        get :home
        get :feature_modules
      end
      resources :feature_modules_configs do
        collection do
          get :index_group
          get :price_of_charge_version
          post :create_group
        end
      end
      get :export_accounts, on: :collection
      get :crm, on: :member
      get :config_guide, on: :member
      get :welcome, on: :member
      get :export_accounts, on: :collection
      resources :system_messages, only: [:index, :show, :destroy] do
        collection do
          post :batch_delete_selected
        end
      end
      resources :recharge_refunds, only: [:index] do
        member do
          post :complete
          post :cancel
        end
      end
      resources :printers, only: [:index]
      resources :printer_codes do
        collection do
          post :bind
        end
      end
      resource :credits_setting, only: [:show, :edit, :update]
      resource :custom_weixin_info do
        resources :home_hot_links, concerns: :change_position
        resources :home_usable_links, concerns: :change_position
      end
      resources :sign_records, only: [:index]
      resources :shifts, only: [:index, :show] do
        get :print, on: :member
      end
      resources :recharge_products, concerns: :change_position
      resources :exchange_codes, only: [:index] do
        put :exchange, on: :member
      end
      resource :email_setting do
        post :test
      end
      resources :one_pages, concerns: :change_position
      resource :table_color
      member do
        get :dashboard
        get :show_search_word
        match :update_search_word, via: [:put, :patch]
        get :edit_search_word
        get :module_index
        get :copy_link
        post :update_sale_employee
      end
      if Rails.env.development?
        resource :test_console do
          get :valid_wechat_users
          get :data_maker_panel
        end
      end

      scope :module => :statistic do
        resources :statistics_caches, only: [:index, :destroy] do
          post :refresh
          delete :clear, on: :collection
        end
        resources :user_statistics, only: [] do
          collection do
            get :new_user
            get :new_vip
            get :subscription_user
            get :user_access
            get :recharge_record
            get :consume_record
            get :recharge_summary
            get :consume_summary
            get :card_log
            get :card_summary
            get :credits_summary
          end
        end

        resources :product_statistics, only: [] do
          collection do
            get :subtract
            get :subtract_summary
            get :gift_product
            get :gift_summary
            get :combo_summary
            get :combo_product
            get :product_summary
            get :category_summary
            get :product_contrast
          end
        end

        resources :business_statistics, only: [] do
          collection do
            get :pay_log
            get :shift
            get :sales_by_day
            get :sales_by_week
            get :sales_by_month
            get :sales_by_year
            get :sales_by_branch
            get :flow_of_customer
            get :promotion
            get :recharge_settle_summary
          end
        end

        resources :coupon_statistics, only: [] do
          collection do
            get :coupon
            get :coupon_summary
            get :voucher
            get :voucher_summary
            get :groupon
            get :groupon_summary
          end
        end

        resources :orders_statistics, only: [] do
          collection do
            get :order_count_by_day
            get :order_count_by_month
            get :order_count_by_year
            get :order_count_by_branch
            get :order_origin
            get :order_discount
            get :change_log
            get :change_log_detail
          end
        end

        resources :table_statistics do
          collection do
            get :summary
            get :rockover_rate_by_day
            get :rockover_rate_by_week
            get :rockover_rate_by_month
          end
        end

        resources :worker_statistics do
          collection do
            get :serve
            get :serve_detail
            get :delivery
          end
        end

        resources :finance_statistics do
          collection do
            get :combi_t1
            get :combi_t2
            get :order_detail
            get :payment
          end
        end
      end

      resources :statistics, only: [] do
        collection do
          get :new_user_by_month
          get :new_user_by_year
          get :wechat_user_by_month
          get :wechat_user_by_year
          get :wechat_user_by_gonghao
          get :sale_value_by_month
          get :sale_value_by_year
          get :sale_amount_by_month
          get :sale_amount_by_year
          get :access_by_month
          get :access_by_year
          get :order_by_month
          get :order_by_year
          get :consume_sort_by_month
          get :consume_sort_by_year
        end
      end
      resources :wechat_share_records
      resources :materials do
        collection do
          get :choose_material
        end
        resources :articles
      end
      resources :articles
      resources :events
      scope :module => :qrcode do
        resources :base_qr_code_scenes
        resources :wechat_qr_code_scenes
        resources :qr_code_scenes do 
          get :edit_bind, on: :member
          match :update_bind, on: :member, via: [:put, :patch]
        end
      end
      resources :roles
      resources :zones
      resources :gift_reasons, concerns: [:change_position]
      resources :subtract_reasons, concerns: [:change_position]
      resources :branch_types do
        get :index_branch_nav, on: :collection
        member do
          get :edit_branch_nav
          match :update_branch_nav, via: [:PUT, :PATCH]
        end
      end
      resources :branch_groups
      scope :module => :shop do
        resources :event_promotions do
          scope :module => :event_promotion do
            resources :promotion_rules, only: [:create, :destroy, :index]
            resources :promotion_actions, only: [:create, :destroy, :index]
          end
        end
        resources :order_promotions do
          scope :module => :order_promotion do
            resources :promotion_rules, only: [:create, :destroy, :index]
            resources :promotion_actions, only: [:create, :destroy, :index]
          end
        end
        resources :pay_methods, concerns: [:change_position]
        resources :pay_method_settings, only: [:index] do
          put :update_all, on: :collection
        end
      end
      scope :module => :product do
        resources :shop_variants, only: [:index]
      end
      scope :module => :order do
        resources :delivery_orders, only: [:index] do
          collection do
            get  :assigned
          end
        end
      end

      resources :tags


      resources :branches do
        member do
          put :change_position
          get :get_erase
          post :erase_data
          post :rollback_data
        end
        resources :item_notes
        resources :essential_products, except: [:show]
        resources :tags
        scope :module => :tag do
          resources :product_tags
          resources :item_note_tags
          resources :branch_tags
        end
        resource :delivery_setting
        resource :bill_template_setting, only: [:show, :edit, :update] do
          get :preview
          put :reset
          put :set_enable
        end
        resources :delivery_zones
        resource :arranging_setting
        resources :delivery_ranges
        resources :waiter_service_items
        resources :cooks, only: [:index, :edit, :update]
        resource :cs_branch_binding
        resources :queue_settings do
          collection do
            get :board
          end
          resources :guest_queues do
            member do
              put :pass
              put :cancel
              put :accept
              put :notify
            end
          end
        end
        resource :reservation_setting
        resource :eat_in_hall_setting
        scope :module => :order do
          concern :order do
            member do
              put :confirm
              put :cancel
              put :complete
              get :other_msg
              get :get_reprint
              get :chooseable_printers
              post :reprint
              put :pay_by_default_method
              get :get_append_pay_item
              put :append_pay_item
              put :destroy_pay_item
              put :clear_appended
            end
          end
          resources :delivery_orders,    only: [:show], concerns: :order do
            member do
              get  :get_assign
              put  :assign
              put  :start
              put  :ship
            end
          end
          resources :reservation_orders, only: [:show], concerns: :order
          resources :eat_in_hall_orders, only: [:show], concerns: :order
          resources :fastfood_orders,    only: [:show], concerns: :order
          resources :groupon_orders,     only: [:show], concerns: :order
          resources :recharge_orders,     only: [:show], concerns: :order
          resources :payment_orders,     only: [:show], concerns: :order

        end
        scope :module => :product do
          resources :products do
            collection do
              post :import_products, to: "products#import_products", as: :import_products
              get :import_failed
              get :error_products
              post :batch_remove
              post :batch_on_shelf
              post :batch_off_shelf
              post :batch_estimate_clear
              post :batch_estimate_full
              post :batch_copy
              get :copy
              get :search
            end
            member do
              put :create_qrcode
              put :change_position
            end
            resources :variants, concerns: :change_position do
              resources :variant_images, concerns: :change_position do
                get :list, on: :collection
                get :add_exist_image, on: :collection
              end
              member do
                post :add_estimate_clear
                post :remove_estimate_clear
                post :add_estimate_clear_reciprocal
                post :ajax_estimate_clear_reciprocal
              end
            end
          end
          resources :option_types, concerns: :change_position
          resources :categories, concerns: :change_position do
            member do
              get :products_actions
              put :update_products
            end
          end
          resources :combos, concerns: :change_position do
            collection do
              post :batch_on_shelf
              post :batch_off_shelf
              post :post_batch_copy
              get :get_batch_copy
            end
            resources :combo_images, concerns: :change_position do
              get :list, on: :collection
              get :add_exist_image, on: :collection
            end
            resources :combo_items, concerns: :change_position
          end
        end
        resources :comments do
          member do
            get :reply
          end
        end
        scope :module => :branch do
          resources :event_promotions do
            scope :module => :event_promotion do
              resources :promotion_rules
              resources :promotion_actions
            end
          end
          resources :order_promotions do
            scope :module => :order_promotion do
              resources :promotion_rules
              resources :promotion_actions
            end
          end
          resources :product_promotions do
            scope :module => :product_promotion do
              resources :promotion_rules
              resources :promotion_actions
            end
          end
          resource :print_setting
          resources :printers do
            post :test_print, on: :member
            post :clear_records, on: :member
            post :toggle, on: :member
            get :get_state, on: :member
            resources :print_records
            get :products, on: :collection
          end
          resources :pay_method_settings, only: [:index] do
            put :update_all, on: :collection
          end
        end
        resource :sale_data_uploader_setting do
          put :upload_base
          post :upload_orders
          post :query_orders
          post :reupload_orders
        end
        resource :kitchen_setting
        resources :tick_accounts do
          resources :tick_account_items, only: [:index] do
            put :complete, on: :member
            put :batch_complete, on: :collection
          end
        end
        resources :reservation_time_points do
          collection do
            get :get_batch_create
            post :post_batch_create
          end
        end
        resources :discount_plans
        resources :table_zones
        resources :tables do
          member do
            get :get_order
            put :enable_qr_code
            put :disable_qr_code
            put :regenerate_qr_code
          end

          collection do
            get :get_export_list
            get :export_all
            get :get_batch_create
            post :post_batch_create
          end
        end

        resources :form_elements do
          collection do
            get 'new_select'
            get 'new_textarea'
            post 'save_sequence'
          end
        end

        resources :accounts do
          resources :locations, only: [:index]
          member do
            get :edit_password
            match :update_password, via: [:put, :patch]
            get :get_bind
            get :bind
            put :unbind
          end
        end
      end
      resources :vip_levels
      resources :vip_infos do
        collection do
          get :applying
          get :get_bindable
          post :remind_bind
          post :import_vip_infos
          get :import_failed
          get :error_vip_infos
          post :destroy_all
        end
        member do
          put :agree
          put :reject
          get :edit_pay_password
          match :update_pay_password, via: [:put, :patch]
        end
      end
      resources :vip_searches do
        member do
          post :compute
          post :recompute
          get :export
          get :get_send_coupon
          post :send_coupon
          get :show_logs
        end
      end
      resources :accounts do
        resources :locations, only: [:index]
        resource :notification_receive_setting, only: [:show, :edit, :update]
        member do
          get :edit_password
          match :update_password, via: [:put, :patch]
          get :unlock
          get :get_bind
          get :bind
          put :unbind
        end
      end

      resources :orders do
        collection do
          post :export_selected
          get :get_export_list
          get :export_all
          post :batch_change_state
          post :batch_change_pay_item_state
          get :anti_settlements
        end
        get :print, on: :member
      end
      scope :module => :wallet do
        concern :wallet do
          get :wallet_logs  , on: :member
        end
        concern :clearing do
          get :get_clearing , on: :member
          put :clearing     , on: :member
        end
        concern :recharge do
          get :get_recharge , on: :member
          put :recharge     , on: :member
        end
        concern :exchange do
          get :get_exchange , on: :member
          put :exchange     , on: :member
        end
        resource :shop_card_wallet do
          get :branches
          get :base_users
          get :wallet_logs
        end
        resource :shop_credits_wallet do
          get :branches
          get :base_users
          get :wallet_logs
        end
        resources :branch_card_wallets    , concerns: [:wallet , :clearing]
        resources :branch_credits_wallets , concerns: [:wallet , :clearing]
        resources :user_card_wallets      , concerns: [:wallet , :exchange, :recharge]
        resources :user_credits_wallets   , concerns: [:wallet , :exchange]
        resources :collection_logs, only: [:index]
        resources :withdraws
      end

      resources :groupon_versions do
        collection do
          get :choose_groupon_branch
        end
      end
      resources :voucher_versions
      resources :coupon_versions
      resources :groupons do
        member do
          post :refund
        end
      end
      resources :vouchers do
        member do
          post :refund
        end
      end
      resources :coupons

      resources :wechat_accounts do
        collection do
          post :auto_config
          get :wechat_users
          get :component_auth
        end
        member do
          match :auto_config, via: [:put, :patch]
          post :upload_server_auth_file
        end
        resources :wechat_menus do
          collection do
            post :sync
          end
          member do
            put :change_position
          end
        end
        resources :keywords_third_party_interfaces

        namespace :shake_around do
          resources :apply_logs
          resources :devices do
            collection do
              get :refresh
            end
            member do
              get :get_bind
              get :bindable
              post :bind
              post :unbind
            end
            resources :shake_infos
          end
          resources :pages do
            collection do
              get :refresh
            end
            member do
              get :get_bind
              get :bindable
              post :bind
              post :unbind
            end
            resources :shake_infos
          end
        end
      end

      scope :module => :user do
        resources :base_users do
          collection do
            get :normal_users
            get :vip_users
            get :find_by_user_open_id
            get :get_send_coupon
            post :send_coupon
          end
          member do
            get :get_recharge_card_wallet
            post :recharge_card_wallet
            match :recharge_card_wallet, via: [:put, :patch]
            get :get_exchange_card_wallet
            post :exchange_card_wallet
            match :exchange_card_wallet, via: [:put, :patch]
            get :get_exchange_credits_wallet
            post :exchange_credits_wallet
            match :exchange_credits_wallet, via: [:put, :patch]
            get :card_wallet_logs
            get :credits_wallet_logs
            get :recharge_orders
          end
        end
        resources :users
        resources :web_users
        resources :phone_users
      end
      resources :short_messages
      resources :order_calls, only: [:index]
      resources :user_wallets, only: [] do
        collection do
          get :card_wallets
        end
      end
      scope :module => :payment do
        resources :payments
        resources :payment_logs
        resource :alipay_methods do
          get :gen_rsa
        end
        resource :wechatpay_method_legacies do
          get :switch_version
        end
        resource :wechatpay_method_v336s do
          get :switch_version
        end
        resource :baidupay_methods
      end

      resources :branch_sliders, concerns: :change_position
      scope :module => :admin do
        resources :weixin_pages
        resources :shop_recharge_records
        resources :cs_branch_bindings
      end
      resources :merchant_applies, only: [:index, :show] do
        member do
          put :confirm
          put :reject
        end
      end
      resources :service_products
      resources :service_product_orders do
        member do
          put 'pay_with_alipay'
        end
      end
      resource :short_message_setting, only: [:show, :edit, :update]
      resource :call_setting, only: [:show, :edit, :update]
      resource :supplies, only: [] do
        collection do
          get :queue_qr_codes
          get :export_queue_qr_code, format: :zip
          get :door_stickers
          get :export_door_sticker, format: :zip
          get :fastfood_stickers
          get :export_fastfood_sticker, format: :zip
        end
      end
      resources :time_intervals
    end

    namespace :crm do
      resources :shops, only: [:show] do
        resources :vip_levels
        resources :recharge_products
        resource :coupon_setting, only: [:show, :update]
        resource :vip_info_setting, only: [:show, :update]
        resource :credits_setting, only: [:show, :update]
        resources :vip_infos, only: [:index, :show, :update, :create] do
          collection do
            post :send_coupon
            post :credits_clear
            post :import
            get :import_failed
            post :batch_destroy
            post :batch_agree_apply_vip
          end
          member do
            post :recharge_card_wallet
            post :exchange_card_wallet
            post :recharge_credits_wallet
            put :agree_apply_vip
            put :reject_apply_vip
            put :block
            get :orders
          end
          resources :coupon_logs, only: [:index]
          resources :card_wallet_logs, only: [:index]
          resources :credits_wallet_logs, only: [:index]
        end
        resources :coupon_versions do
          resources :coupon_photos, only: [:index, :create] do
            post :batch_destroy, on: :collection
          end
        end
        resources :branches, only: [:index]
        resources :branch_groups, only: [:index]
        resources :coupons, only: [:index]
      end
    end

    authenticate :account, lambda { |u| u.is_admin? } do
      mount Sidekiq::Web, at: '/sidekiq', as: :sidekiq_web
    end
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
            # Store management (Phase R7)
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
            # Marketing (Phase R7)
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
          # Marketing (Phase R7)
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
          # CRM (Phase R7)
          namespace :crm do
            resources :vip_levels, only: [:index, :show, :create, :update, :destroy]
            resources :recharge_products, only: [:index, :show, :create, :update, :destroy] do
              member do
                put :change_position
              end
            end
            resource :credits_setting, only: [:show, :update]
          end
          # System settings (Phase R7)
          namespace :system do
            resources :roles, only: [:index, :show, :create, :update, :destroy]
            resources :printers, only: [:index, :show]
            resources :notification_settings, only: [:show, :update], param: :account_id
          end
        end
      end
    end

    # Admin API v1 — clean URL namespace for Vue 3 Admin frontend
    # Maps /api/admin/v1/* to Ddt::Api::Admin::V1::* controllers
    namespace :admin do
      namespace :v1 do
        # Marketing
        resources :vouchers, only: [:index, :show] do
          member { post :refund }
        end
        resources :groups, controller: 'groupons', only: [:index, :show] do
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
        resources :orders, only: [:index, :show, :update]
        resources :payments, only: [:index, :show]
      end
    end
  end
end
