module Ddt
  module ActionFeatureRel
    class << self

      #
      # struct:
      #   {controller_name:  (actions || special_action) => (feature||features||proc)}
      # special_action:
      #   all: all actions
      #


    def other
      {
        #doorkeeper/authorizations#show|new|create|destroy
        authorizations: {:all => :model_authorization},
        #doorkeeper/tokens#create|revoke
        tokens: {:all => :model_token},
        #doorkeeper/applications#index|create|new|edit|show|update|update|destroy
        applications: {:all => :model_application},
        #doorkeeper/authorized_applications#index|destroy
        authorized_applications: {:all => :model_authorized_application},
        #doorkeeper/token_info#show
        token_info: {:all => :model_token_info},
        #ddt/oauth_api/accounts#show
        accounts: {:all => :model_account},
        #ddt/oauth_api/products#index
        products: {:all => :model_product},
        #ddt/oauth_api/branches#index
        branches: {:all => :model_branch},
        #ddt/webstore/shops#show
        shops: {:all => :model_shop},
        #ddt/common/js_error_report#create
        js_error_report: {:all => :model_js_error_report},
        #ddt/common/cloopen_call_resp#create
        cloopen_call_resp: {:all => :model_cloopen_call_resp},
        #ddt/common/weixin#weixin_oauth_callback|wechat_account_oauth_callback
        weixin: {:all => :model_weixin},
        #ddt/common/messages#validate|create
        messages: {:all => :model_message},
        #ddt/common/qr_code_scenes#show
        qr_code_scenes: {:all => :model_qr_code_scene},
        #ddt/common/verify_vip_info_qr_code_scenes#verify|show
        verify_vip_info_qr_code_scenes: {:all => :model_verify_vip_info_qr_code_scene},
        #ddt/common/verify_vip_infos#verify|show
        verify_vip_infos: {:all => :model_verify_vip_info},
        #ddt/common/reporters#show|index
        reporters: {:all => :model_reporter},
        #ddt/common/shops#index|create|new|edit|show|update|update|destroy
        shops: {:all => :model_shop},
        #ddt/common/clear_cookies#clear_cookies
        clear_cookies: {:all => :model_clear_cooky},
        #ddt/oapi/webapi/debug#auto_login
        debug: {:all => :model_debug},
        #ddt/webapi/statistics#new_user_by_month|new_user_by_year|wechat_user_by_month|wechat_user_by_year|wechat_user_by_gonghao|sale_value_by_month|sale_value_by_year|sale_amount_by_month|sale_amount_by_year|access_by_month|access_by_year|order_by_month|order_by_year|consume_sort_by_month|consume_sort_by_year|index|create|new|edit|show|update|update|destroy
        statistics: {:all => :model_statistic},
        #ddt/system_alipays#system_alipay_notify
        system_alipays: {:all => :model_system_alipay},
        #ddt/protocols#index
        protocols: {:all => :model_protocol},
      }
    end


    def common_api
      {
        #ddt/common_api/v1/shops#show {:format=>"json"}
        shops: {:all => :model_shop},
        #ddt/common_api/v1/accounts#login {:format=>"json"}|logout {:format=>"json"}|auth {:format=>"json"}|update_channel {:format=>"json"}|send_sms_captcha {:format=>"json"}|register {:format=>"json"}|report_location {:format=>"json"}|permissions {:format=>"json"}|show {:format=>"json"}|update {:format=>"json"}|index {:format=>"json"}|create {:format=>"json"}|update {:format=>"json"}|update {:format=>"json"}|destroy {:format=>"json"}
        accounts: {:all => :model_account},
        #ddt/common_api/v1/roles#index {:format=>"json"}
        roles: {:all => :model_role},
        #ddt/common_api/v1/notifications#pull {:format=>"json"}|index {:format=>"json"}|create {:format=>"json"}|new {:format=>"json"}|edit {:format=>"json"}|show {:format=>"json"}|update {:format=>"json"}|update {:format=>"json"}|destroy {:format=>"json"}
        notifications: {:all => :model_notification},
        #ddt/common_api/v1/vip_infos#get_by_scan_code {:format=>"json"}
        vip_infos: {:all => :model_vip_info},
        #ddt/common_api/v1/credits_wallets#exchange {:format=>"json"}|recharge {:format=>"json"}
        credits_wallets: {:all => :model_credits_wallet},
        #ddt/common_api/v1/notification_receive_settings#update {:format=>"json"}|show {:format=>"json"}|update {:format=>"json"}|update {:format=>"json"}
        notification_receive_settings: {:all => :model_notification_receive_setting},
        #ddt/common_api/v1/labels#subtract {:format=>"json"}|gift {:format=>"json"}|service {:format=>"json"}
        labels: {:all => :model_label},
        #ddt/common_api/v1/statistics#result {:format=>"json"}|last_shift {:format=>"json"}|index {:format=>"json"}
        statistics: {:all => :model_statistic},
        #ddt/common_api/v1/branches#cache_versions {:format=>"json"}|update {:format=>"json"}|index {:format=>"json"}|show {:format=>"json"}|update {:format=>"json"}|update {:format=>"json"}
        branches: {:all => :model_branch},
        #ddt/common_api/v1/printers#reprint {:format=>"json"}|test_print {:format=>"json"}|update {:format=>"json"}|index {:format=>"json"}|create {:format=>"json"}|show {:format=>"json"}|update {:format=>"json"}|update {:format=>"json"}
        printers: {:all => :model_printer},
        #ddt/common_api/v1/products#update {:format=>"json"}|index {:format=>"json"}|update {:format=>"json"}|update {:format=>"json"}
        products: {:all => :model_product},
        #ddt/common_api/v1/categories#index {:format=>"json"}
        categories: {:all => :model_category},
        #ddt/common_api/v1/combos#update {:format=>"json"}|add_combo_package {:format=>"json"}|index {:format=>"json"}|show {:format=>"json"}|update {:format=>"json"}|update {:format=>"json"}
        combos: {:all => :model_combo},
        #ddt/common_api/v1/table_zones#with_tables {:format=>"json"}|with_reservation_time_points {:format=>"json"}|index {:format=>"json"}
        table_zones: {:all => :model_table_zone},
        #ddt/common_api/v1/tables#search {:format=>"json"}|open {:format=>"json"}|clear {:format=>"json"}|check_out {:format=>"json"}|cancel_check_out {:format=>"json"}|index {:format=>"json"}|show {:format=>"json"}
        tables: {:all => :model_table},
        #ddt/common_api/v1/queue_settings#index {:format=>"json"}
        queue_settings: {:all => :model_queue_setting},
        #ddt/common_api/v1/guest_queues#pass {:format=>"json"}|cancel {:format=>"json"}|requeue {:format=>"json"}|accept {:format=>"json"}|notify {:format=>"json"}|reprint {:format=>"json"}|print_pre_order {:format=>"json"}|index {:format=>"json"}|create {:format=>"json"}|show {:format=>"json"}
        guest_queues: {:all => :model_guest_queue},
        #ddt/common_api/v1/item_notes#index {:format=>"json"}
        item_notes: {:all => :model_item_note},
        #ddt/common_api/v1/base_coupons#find_by_code {:format=>"json"}|exchange {:format=>"json"}
        base_coupons: {:all => :model_base_coupon},
        #ddt/common_api/v1/order/eat_in_hall_orders#change_table {:format=>"json"}|merge_table {:format=>"json"}|move_itemable {:format=>"json"}|append {:format=>"json"}|active_line_items {:format=>"json"}|subtract {:format=>"json"}|call_waiter {:format=>"json"}|update_guest_num {:format=>"json"}|request_pay {:format=>"json"}|confirm {:format=>"json"}|complete {:format=>"json"}|cancel {:format=>"json"}|change_vip_info {:format=>"json"}|unbind_vip_info {:format=>"json"}|credits_deduction {:format=>"json"}|card_deduction {:format=>"json"}|hasten {:format=>"json"}|reprint {:format=>"json"}|create {:format=>"json"}|show {:format=>"json"}
        eat_in_hall_orders: {:all => :model_eat_in_hall_order},
        #ddt/common_api/v1/order/fastfood_orders#confirm {:format=>"json"}|complete {:format=>"json"}|cancel {:format=>"json"}|change_vip_info {:format=>"json"}|unbind_vip_info {:format=>"json"}|credits_deduction {:format=>"json"}|card_deduction {:format=>"json"}|hasten {:format=>"json"}|reprint {:format=>"json"}|show {:format=>"json"}
        fastfood_orders: {:all => :model_fastfood_order},
        #ddt/common_api/v1/order/delivery_orders#append {:format=>"json"}|active_line_items {:format=>"json"}|subtract {:format=>"json"}|assign_delivery_man {:format=>"json"}|finish_delivery {:format=>"json"}|start_delivery {:format=>"json"}|confirm {:format=>"json"}|complete {:format=>"json"}|cancel {:format=>"json"}|change_vip_info {:format=>"json"}|unbind_vip_info {:format=>"json"}|credits_deduction {:format=>"json"}|card_deduction {:format=>"json"}|hasten {:format=>"json"}|reprint {:format=>"json"}|show {:format=>"json"}
        delivery_orders: {:all => :model_delivery_order},
        #ddt/common_api/v1/order/reservation_orders#confirm {:format=>"json"}|complete {:format=>"json"}|cancel {:format=>"json"}|change_vip_info {:format=>"json"}|unbind_vip_info {:format=>"json"}|credits_deduction {:format=>"json"}|card_deduction {:format=>"json"}|hasten {:format=>"json"}|reprint {:format=>"json"}|show {:format=>"json"}
        reservation_orders: {:all => :model_reservation_order},
        #ddt/common_api/v1/order/groupon_orders#confirm {:format=>"json"}|complete {:format=>"json"}|cancel {:format=>"json"}|change_vip_info {:format=>"json"}|unbind_vip_info {:format=>"json"}|credits_deduction {:format=>"json"}|card_deduction {:format=>"json"}|hasten {:format=>"json"}|reprint {:format=>"json"}|show {:format=>"json"}
        groupon_orders: {:all => :model_groupon_order},
        #ddt/common_api/v1/order/payment_orders#confirm {:format=>"json"}|complete {:format=>"json"}|cancel {:format=>"json"}|change_vip_info {:format=>"json"}|unbind_vip_info {:format=>"json"}|credits_deduction {:format=>"json"}|card_deduction {:format=>"json"}|hasten {:format=>"json"}|reprint {:format=>"json"}|create {:format=>"json"}|show {:format=>"json"}
        payment_orders: {:all => :model_payment_order},
        #ddt/common_api/v1/order/pay_items#clear {:format=>"json"}|paid_all {:format=>"json"}|paid {:format=>"json"}|get_pay_online {:format=>"json"}|pay_by_seller_scan {:format=>"json"}|create {:format=>"json"}|show {:format=>"json"}
        pay_items: {:all => :model_pay_item},
        #ddt/common_api/v1/order/orders#index {:format=>"json"}|show {:format=>"json"}
        orders: {:all => :model_order},
      }.map do |rel|
        rule = rel[1]
        rule.each do |k, v|
          v = [v] unless v.is_a? Array
          rule[k] = ->(request){
            terminal_id = request.params[:terminal_id]
            if terminal_id.present?
              if terminal_id.start_with?('app')
                v.unshift :app_api
              elsif terminal_id.start_with?('smart_pos')

              elsif terminal_id.start_with?('pad')
                v.unshift :pad_api
              elsif terminal_id.to_s.downcase.start_with?('cs') || terminal_id.to_s.downcase.start_with?('printer')
                # cs or printer
              else
                raise "UNKnow Source: #{terminal_id}"
              end
            else
              if 'com.pinmi.ddt.seller' == request.env['HTTP_X_REQUESTED_WITH']
                v.unshift :app_api
              elsif 'com.pinmi.cookbook' == request.env['HTTP_X_REQUESTED_WITH']
                v.unshift :pad_api
              else
                raise "Common_api: params[:terminal_id] Not Exist?"
              end
            end
          }
        end
        [rel[0], rule]
      end.to_h
    end


    def webpos
      {
        #ddt/webpos/webpos_accounts/sessions#new|create|destroy
        sessions: {:all => :model_session},
        #ddt/webpos/home#index|kitchen|users|queue|bill|estimate
        home: {:all => :model_home},
        #ddt/webpos/accounts#bosses_and_workers|authorization|get_authorizers|permissions|show
        accounts: {:all => :model_account},
        #ddt/webpos/extended_form/orders#index|create|new|edit|show|update|update|destroy
        orders: {:all => :model_order},
        #ddt/webpos/extended_form/shops#index|create|new|edit|show|update|update|destroy
        shops: {:all => :model_shop},
        #ddt/webpos/abilities#show
        abilities: {:all => :model_ability},
        #ddt/webpos/vip_levels#index
        vip_levels: {:all => :model_vip_level},
        #ddt/webpos/gift_reasons#index
        gift_reasons: {:all => :model_gift_reason},
        #ddt/webpos/recharge_products#index
        recharge_products: {:all => :model_recharge_product},
        #ddt/webpos/temp_recharge_products#create
        temp_recharge_products: {:all => :model_temp_recharge_product},
        #ddt/webpos/vip_infos#get_by_scan_code|wallet_logs|merge|become|reject|update|index|create|show
        vip_infos: {:all => :model_vip_info},
        #ddt/webpos/card_wallet_logs#change_note
        card_wallet_logs: {:all => :model_card_wallet_log},
        #ddt/webpos/addresses#search
        addresses: {:all => :model_address},
        #ddt/webpos/reservation_infos#search
        reservation_infos: {:all => :model_reservation_info},
        #ddt/webpos/qr_codes#verify_vip_info|reload_verify_qrcode
        qr_codes: {:all => :model_qr_code},
        #ddt/webpos/statistics#product_sales|order_quantity
        statistics: {:all => :model_statistic},
        #ddt/webpos/user_card_wallets#recharge|exchange
        user_card_wallets: {:all => :model_user_card_wallet},
        #ddt/webpos/user_credits_wallets#exchange|get
        user_credits_wallets: {:all => :model_user_credits_wallet},
        #ddt/webpos/branches#open_shift|close_shift|get_shift|print_shift|waiter_names|sdu_upload_orders|sdu_query_orders|cache_versions|index|show
        branches: {:all => :model_branch},
        #ddt/webpos/bill_centers#discount_list|waiter_list|gift_item_list|subtract_item_list|sale_list|payment_list|shift_list|combo_package_list|anti_settlement_list|order_cancel_list|queue_list|by_weight_product_list
        bill_centers: {:all => :model_bill_center},
        #ddt/webpos/discount_plans#index
        discount_plans: {:all => :model_discount_plan},
        #ddt/webpos/item_notes#index
        item_notes: {:all => :model_item_note},
        #ddt/webpos/tick_accounts#index
        tick_accounts: {:all => :model_tick_account},
        #ddt/webpos/delivery_mans#index
        delivery_mans: {:all => :model_delivery_man},
        #ddt/webpos/delivery_zones#index
        delivery_zones: {:all => :model_delivery_zone},
        #ddt/webpos/delivery_dates#index
        delivery_dates: {:all => :model_delivery_date},
        #ddt/webpos/form_elements#index
        form_elements: {:all => :model_form_element},
        #ddt/webpos/printers#reprint|index
        printers: {:all => :model_printer},
        #ddt/webpos/litps#confirm|complete|cooks|counts|index
        litps: {:all => :model_litp},
        #ddt/webpos/table_zones#with_reservation_time_points|index|index
        table_zones: {:all => :model_table_zone},
        #ddt/webpos/tables#get_changed_tables|get_reservation_tables|open|clear|check_out|cancel_check_out|update_guest_num|bind_table|unbind_table|force_clear|index|show
        tables: {:all => :model_table},
        #ddt/webpos/categories#index|show
        categories: {:all => :model_category},
        #ddt/webpos/products#index
        products: {:all => :model_product},
        #ddt/webpos/combos#add_combo_package|index
        combos: {:all => :model_combo},
        #ddt/webpos/variant_packages#create|update|update
        variant_packages: {:all => :model_variant_package},
        #ddt/webpos/order/eat_in_hall_orders#change_table|merge_table|move_itemable|append|active_line_items|subtract|bind_reservation_order|anti_settlement|trace_waiter|allow_selfpay|update_guest_num|change_weight|confirm|complete|cancel|change_vip_info|unbind_vip_info|credits_deduction|cancel_credits_deduction|card_deduction|privilege_discount|privilege_reduction|privilege_free|moling|cancel_privilege_discount|cancel_privilege_reduction|cancel_privilege_free|cancel_moling|apply_coupon|rollback_coupon|apply_voucher|rollback_voucher|bill|create_pay_items|pay_all_pay_items|clear_pay_items|hasten|add_discount_plan|cancel_discount_plan|add_disabled_promotion|remove_disabled_promotion|create|show
        eat_in_hall_orders: {:all => :model_eat_in_hall_order},
        #ddt/webpos/order/fastfood_orders#call_customer|anti_settlement|confirm|complete|cancel|change_vip_info|unbind_vip_info|credits_deduction|cancel_credits_deduction|card_deduction|privilege_discount|privilege_reduction|privilege_free|moling|cancel_privilege_discount|cancel_privilege_reduction|cancel_privilege_free|cancel_moling|apply_coupon|rollback_coupon|apply_voucher|rollback_voucher|bill|create_pay_items|pay_all_pay_items|clear_pay_items|hasten|add_discount_plan|cancel_discount_plan|add_disabled_promotion|remove_disabled_promotion|create|show
        fastfood_orders: {:all => :model_fastfood_order},
        #ddt/webpos/order/reservation_orders#change_to_eat_in_hall|bind_table|edit_reservation_info|confirm|complete|cancel|change_vip_info|unbind_vip_info|credits_deduction|cancel_credits_deduction|card_deduction|privilege_discount|privilege_reduction|privilege_free|moling|cancel_privilege_discount|cancel_privilege_reduction|cancel_privilege_free|cancel_moling|apply_coupon|rollback_coupon|apply_voucher|rollback_voucher|bill|create_pay_items|pay_all_pay_items|clear_pay_items|hasten|add_discount_plan|cancel_discount_plan|add_disabled_promotion|remove_disabled_promotion|create|show
        reservation_orders: {:all => :model_reservation_order},
        #ddt/webpos/order/delivery_orders#assign_delivery_man|append|active_line_items|subtract|confirm|complete|cancel|change_vip_info|unbind_vip_info|credits_deduction|cancel_credits_deduction|card_deduction|privilege_discount|privilege_reduction|privilege_free|moling|cancel_privilege_discount|cancel_privilege_reduction|cancel_privilege_free|cancel_moling|apply_coupon|rollback_coupon|apply_voucher|rollback_voucher|bill|create_pay_items|pay_all_pay_items|clear_pay_items|hasten|add_discount_plan|cancel_discount_plan|add_disabled_promotion|remove_disabled_promotion|create|show
        delivery_orders: {:all => :model_delivery_order},
        #ddt/webpos/order/groupon_orders#confirm|complete|cancel|change_vip_info|unbind_vip_info|credits_deduction|cancel_credits_deduction|card_deduction|privilege_discount|privilege_reduction|privilege_free|moling|cancel_privilege_discount|cancel_privilege_reduction|cancel_privilege_free|cancel_moling|apply_coupon|rollback_coupon|apply_voucher|rollback_voucher|bill|create_pay_items|pay_all_pay_items|clear_pay_items|hasten|add_discount_plan|cancel_discount_plan|add_disabled_promotion|remove_disabled_promotion|show
        groupon_orders: {:all => :model_groupon_order},
        #ddt/webpos/order/payment_orders#confirm|complete|cancel|change_vip_info|unbind_vip_info|credits_deduction|cancel_credits_deduction|card_deduction|privilege_discount|privilege_reduction|privilege_free|moling|cancel_privilege_discount|cancel_privilege_reduction|cancel_privilege_free|cancel_moling|apply_coupon|rollback_coupon|apply_voucher|rollback_voucher|bill|create_pay_items|pay_all_pay_items|clear_pay_items|hasten|add_discount_plan|cancel_discount_plan|add_disabled_promotion|remove_disabled_promotion|create|show
        payment_orders: {:all => :model_payment_order},
        #ddt/webpos/order/recharge_orders#confirm|complete|cancel|change_vip_info|unbind_vip_info|credits_deduction|cancel_credits_deduction|card_deduction|privilege_discount|privilege_reduction|privilege_free|moling|cancel_privilege_discount|cancel_privilege_reduction|cancel_privilege_free|cancel_moling|apply_coupon|rollback_coupon|apply_voucher|rollback_voucher|bill|create_pay_items|pay_all_pay_items|clear_pay_items|hasten|add_discount_plan|cancel_discount_plan|add_disabled_promotion|remove_disabled_promotion|create|show
        recharge_orders: {:all => :model_recharge_order},
        #ddt/webpos/order/orders#pending_counts|batch_change_state|index|show
        orders: {:all => :model_order},
        #ddt/webpos/order/pay_items#paid|get_pay_online|pay_by_seller_scan|index|create|new|edit|show|update|update|destroy
        pay_items: {:all => :model_pay_item},
        #ddt/webpos/order/line_items#change_price|index|create|new|edit|show|update|update|destroy
        line_items: {:all => :model_line_item},
        #ddt/webpos/queue_settings#history|queue_states|create_guest_queue|set_notify_number_in_advance|index
        queue_settings: {:all => :model_queue_setting},
        #ddt/webpos/guest_queues#pass|cancel|requeue|accept|notify|reprint|print_pre_order|pre_order_bill|bill|index|create|show
        guest_queues: {:all => :model_guest_queue},
        #ddt/webpos/coupon/coupons#search|available|find_by_code|exchange_by_code|apply
        coupons: {:all => :model_coupon},
        #ddt/webpos/coupon/groupons#available|find_by_code|exchange_by_code|exchange_by_id
        groupons: {:all => :model_groupon},
        #ddt/webpos/coupon/vouchers#search|available|find_by_code|exchange_by_code|exchange_by_id
        vouchers: {:all => :model_voucher},
        #ddt/webpos/estimate_clear#add|remove|add_reciprocal|remove_reciprocal|clear|index
        estimate_clear: {:all => :model_estimate_clear},
        #ddt/webpos/time_intervals#index
        time_intervals: {:all => :model_time_interval},
        #ddt/webpos/shops#show
        shops: {:all => :model_shop},
      }.merge({
        home: {:all => :model_shop}
      })
    end


    def agentsys
      {
        #ddt/agentsys/agents/sessions#new|create|destroy
        sessions: {:all => :model_session},
        #ddt/agentsys/agents/passwords#create|new|edit|update|update
        passwords: {:all => :model_password},
        #ddt/agentsys/agents/registrations#cancel|create|new|edit|update|update|destroy
        registrations: {:all => :model_registration},
        #ddt/agentsys/shops#index|follow|give_up|index|create|new|edit|show|update|update|destroy
        shops: {:all => :model_shop},
        #ddt/agentsys/agent_printers#get_purchase|post_purchase|index|create|new|edit|show|update|update|destroy
        agent_printers: {:all => :model_agent_printer},
        #ddt/agentsys/agent_materials#index|create|new|edit|show|update|update|destroy
        agent_materials: {:all => :model_agent_material},
        #ddt/agentsys/users#index
        users: {:all => :model_user},
        #ddt/agentsys/lisences#bind|activate|index|create|new|edit|show|update|update|destroy
        lisences: {:all => :model_lisence},
        #ddt/agentsys/agents#profile|edit_profile|update_profile
        agents: {:all => :model_agent},
      }
    end


    def weixin
      {
        #ddt/weixin/shops#show|my|cart|order|queue|manage|index|create|new|edit|show|update|update|destroy
        shops: {:all => :model_shop},
        #ddt/weixin/bind_orders#bind|show
        bind_orders: {:all => :model_bind_order},
        #ddt/weixin/recharge_products#index
        recharge_products: {:all => :model_recharge_product},
        #ddt/weixin/wechat_share_records#confirm|index|create|new|edit|show|update|update|destroy
        wechat_share_records: {:all => :model_wechat_share_record},
        #ddt/weixin/sharable_coupons#receive|index|create|new|edit|show|update|update|destroy
        sharable_coupons: {:all => :model_sharable_coupon},
        #ddt/weixin/censor_reports#create
        censor_reports: {:all => :model_censor_report},
        #ddt/weixin/promotions#index|create|new|edit|show|update|update|destroy
        promotions: {:all => :model_promotion},
        #ddt/weixin/tuans#index|show
        tuans: {:all => :model_tuan},
        #ddt/weixin/zones#get_zone_by_city|index
        zones: {:all => :model_zone},
        #ddt/weixin/exchange_codes#get_permissions|get_qrcode|exchange|index|create|new|edit|show|update|update|destroy
        exchange_codes: {:all => :model_exchange_code},
        #ddt/weixin/order/deliveryman_orders#index|create|new|edit|show|update|update|destroy
        deliveryman_orders: {:all => :model_deliveryman_order},
        #ddt/weixin/branches#filters|index|create|new|edit|show|update|update|destroy
        branches: {:all => :model_branch},
        #ddt/weixin/products#index|create|new|edit|show|update|update|destroy
        products: {:all => :model_product},
        #ddt/weixin/combos#add_combo_package|index
        combos: {:all => :model_combo},
        #ddt/weixin/comments#index|create|new|edit|show|update|update|destroy
        comments: {:all => :model_comment},
        #ddt/weixin/invoices#create
        invoices: {:all => :model_invoice},
        #ddt/weixin/guest_queues#cancel|bind_user|get_by_qr_code|create|new|edit|show|update|update|destroy
        guest_queues: {:all => :model_guest_queue},
        #ddt/weixin/combo_packages#index|create|new|edit|show|update|update|destroy
        combo_packages: {:all => :model_combo_package},
        #ddt/weixin/categories#index|create|new|edit|show|update|update|destroy
        categories: {:all => :model_category},
        #ddt/weixin/table_zones#index|create|new|edit|show|update|update|destroy
        table_zones: {:all => :model_table_zone},
        #ddt/weixin/tables#open|show
        tables: {:all => :model_table},
        #ddt/weixin/order_itemables#plus|minus|index
        order_itemables: {:all => :model_order_itemable},
        #ddt/weixin/reservation_time_points#index|create|new|edit|show|update|update|destroy
        reservation_time_points: {:all => :model_reservation_time_point},
        #ddt/weixin/cart/delivery_carts#update_shipment|add_itemable|remove_itemable|clear|update_cart|update|add_combo_package|apply_coupon|clear_coupon|create|new|edit|show|update|update|destroy
        delivery_carts: {:all => :model_delivery_cart},
        #ddt/weixin/cart/reservation_carts#update_reservation_info|add_itemable|remove_itemable|clear|update_cart|update|add_combo_package|create|new|edit|show|update|update|destroy
        reservation_carts: {:all => :model_reservation_cart},
        #ddt/weixin/cart/eat_in_hall_carts#update_table_info|set_order_itemables_from_table|add_itemable|remove_itemable|clear|update_cart|update|add_combo_package|apply_coupon|clear_coupon|create|new|edit|show|update|update|destroy
        eat_in_hall_carts: {:all => :model_eat_in_hall_cart},
        #ddt/weixin/cart/fastfood_carts#add_itemable|remove_itemable|clear|update_cart|update|add_combo_package|apply_coupon|clear_coupon|create|new|edit|show|update|update|destroy
        fastfood_carts: {:all => :model_fastfood_cart},
        #ddt/weixin/cart/groupon_carts#add_tuan|add_itemable|remove_itemable|clear|update_cart|update|add_combo_package|create|new|edit|show|update|update|destroy
        groupon_carts: {:all => :model_groupon_cart},
        #ddt/weixin/cart/recharge_carts#add_recharge_product|add_itemable|remove_itemable|clear|update_cart|update|add_combo_package|create|new|edit|show|update|update|destroy
        recharge_carts: {:all => :model_recharge_cart},
        #ddt/weixin/order/delivery_orders#hasten|refresh_location|ship|start_shipment|finish_shipment|assign_to_self|prepare_pay_online|get_pay_online|cancel|confirm|complete|append_itemables|get_permissions|avariable_coupons|association_domains|index|create|show
        delivery_orders: {:all => :model_delivery_order},
        #ddt/weixin/order/reservation_orders#prepare_pay_online|get_pay_online|cancel|confirm|complete|append_itemables|get_permissions|avariable_coupons|association_domains|create|show
        reservation_orders: {:all => :model_reservation_order},
        #ddt/weixin/order/eat_in_hall_orders#get_order_by_table|hasten|call_waiter|request_pay|update|prepare_pay_online|get_pay_online|cancel|confirm|complete|append_itemables|get_permissions|avariable_coupons|association_domains|apply_coupon|clear_coupon|create|show
        eat_in_hall_orders: {:all => :model_eat_in_hall_order},
        #ddt/weixin/order/fastfood_orders#hasten|call_waiter|prepare_pay_online|get_pay_online|cancel|confirm|complete|append_itemables|get_permissions|avariable_coupons|association_domains|create|show
        fastfood_orders: {:all => :model_fastfood_order},
        #ddt/weixin/order/groupon_orders#prepare_pay_online|get_pay_online|cancel|confirm|complete|append_itemables|get_permissions|avariable_coupons|association_domains|create|show
        groupon_orders: {:all => :model_groupon_order},
        #ddt/weixin/order/recharge_orders#prepare_pay_online|get_pay_online|cancel|confirm|complete|append_itemables|get_permissions|avariable_coupons|association_domains|create|show
        recharge_orders: {:all => :model_recharge_order},
        #ddt/weixin/order/payment_orders#prepare_pay_online|get_pay_online|cancel|confirm|complete|append_itemables|get_permissions|avariable_coupons|association_domains|create|show
        payment_orders: {:all => :model_payment_order},
        #ddt/weixin/order/order_comments#create|new|edit|show|update|update|destroy
        order_comments: {:all => :model_order_comment},
        #ddt/weixin/order/orders#index|create|new|edit|show|update|update|destroy
        orders: {:all => :model_order},
        #ddt/weixin/order/invitation_orders#agree|disagree|show
        invitation_orders: {:all => :model_invitation_order},
        #ddt/weixin/articles#show
        articles: {:all => :model_article},
        #ddt/weixin/vip_info_settings#show
        vip_info_settings: {:all => :model_vip_info_setting},
        #ddt/weixin/user/order/delivery_orders#index
        delivery_orders: {:all => :model_delivery_order},
        #ddt/weixin/user/order/reservation_orders#index
        reservation_orders: {:all => :model_reservation_order},
        #ddt/weixin/user/order/eat_in_hall_orders#index
        eat_in_hall_orders: {:all => :model_eat_in_hall_order},
        #ddt/weixin/user/order/fastfood_orders#index
        fastfood_orders: {:all => :model_fastfood_order},
        #ddt/weixin/user/order/groupon_orders#index
        groupon_orders: {:all => :model_groupon_order},
        #ddt/weixin/user/order/recharge_orders#index
        recharge_orders: {:all => :model_recharge_order},
        #ddt/weixin/user/order/payment_orders#index
        payment_orders: {:all => :model_payment_order},
        #ddt/weixin/user/users#authenticate_password|update_location|update_vip_info|send_vip_info_phone_validation_code|scan_code|apply_vip|update_pay_password|send_validation_code|bind_vip|is_correct_code|show|card_wallet_logs|credits_wallet_logs
        users: {:all => :model_user},
        #ddt/weixin/user/addresses#set_default|destroy|update|index|create|show
        addresses: {:all => :model_address},
        #ddt/weixin/user/coupon/coupon_versions#exchange|index|show
        coupon_versions: {:all => :model_coupon_version},
        #ddt/weixin/user/coupon/coupons#status|index|show
        coupons: {:all => :model_coupon},
        #ddt/weixin/user/coupon/groupons#apply_refund|cancel_apply_refund|index|show
        groupons: {:all => :model_groupon},
        #ddt/weixin/user/coupon/vouchers#apply_refund|cancel_apply_refund|index|show
        vouchers: {:all => :model_voucher},
        #ddt/weixin/user/sharable_coupons#index|create|new|edit|show|update|update|destroy
        sharable_coupons: {:all => :model_sharable_coupon},
        #ddt/weixin/user/sign_records#index|create|new|edit|show|update|update|destroy
        sign_records: {:all => :model_sign_record},
        #ddt/weixin/user/favorite_branches#destroy|index|create|show
        favorite_branches: {:all => :model_favorite_branch},
        #ddt/weixin/user/merchant_applies#cancel|create|show
        merchant_applies: {:all => :model_merchant_apply},
      }.merge({
        # adjust
        vip_info_settings: {:all => :model_user},
        users: {
          [:update_location, :show] => :model_user,
          [:credits_wallet_logs] => :model_credits_wallet_log,
          :all => :model_vip_info
        }
      }).map do |rel|
        rule = rel[1]
        rule.each do |k, v|
          v = [v] unless v.is_a? Array
          rule[k] = v.unshift :wechat_api
        end
        [rel[0], rule]
      end.to_h
    end


    def backend
      {
        #ddt/backend/account/sessions#new|create|destroy|new
        sessions: {:all => :model_session},
        #ddt/backend/account/passwords#create|new|edit|update|update
        passwords: {:all => :model_password},
        #ddt/backend/account/registrations#cancel|create|new|edit|update|update|destroy|check_unique|check_sms_captcha|register_success|send_sms_captcha
        registrations: {:all => :model_registration},
        #ddt/backend/account/unlocks#create|new|show
        unlocks: {:all => :model_unlock},
        #ddt/backend/admin/sms_captchas#index
        sms_captchas: {:all => :model_sms_captcha},
        #ddt/backend/admin/js_errors#index|create|new|edit|show|update|update|destroy
        js_errors: {:all => :model_js_error},
        #ddt/backend/admin/app_versions#index|create|new|edit|show|update|update|destroy
        app_versions: {:all => :model_app_version},
        #ddt/backend/admin/jokes#index|create|new|edit|show|update|update|destroy
        jokes: {:all => :model_joke},
        #ddt/backend/admin/variant_images#batch_set|index|create|new|edit|show|update|update|destroy
        variant_images: {:all => :model_variant_image},
        #ddt/backend/admin/combo_images#batch_set|index|create|new|edit|show|update|update|destroy
        combo_images: {:all => :model_combo_image},
        #ddt/backend/admin/asset_tags#index|create|new|edit|show|update|update|destroy
        asset_tags: {:all => :model_asset_tag},
        #ddt/backend/admin/pre_sale_staffs#index|create|new|edit|show|update|update|destroy
        pre_sale_staffs: {:all => :model_pre_sale_staff},
        #ddt/backend/admin/sale_employees#statistic|index|create|new|edit|show|update|update|destroy
        sale_employees: {:all => :model_sale_employee},
        #ddt/backend/admin/admin_statistics#visit_data|order_data|order_types|order_origins|pay_types|queue_origins|notification_data|shop_data|index|create|new|edit|show|update|update|destroy
        admin_statistics: {:all => :model_admin_statistic},
        #ddt/backend/admin/censor_reports#confirm|reject|ban|cancel_ban|index|create|new|edit|show|update|update|destroy
        censor_reports: {:all => :model_censor_report},
        #ddt/backend/admin/withdraws#complete|cancel|index
        withdraws: {:all => :model_withdraw},
        #ddt/backend/admin/shop_recharge_records#index|show|index|create|new|edit|show|update|update|destroy
        shop_recharge_records: {:all => :model_shop_recharge_record},
        #ddt/backend/admin/cs_branch_bindings#index|create|show|index|create|new|edit|show|update|update|destroy
        cs_branch_bindings: {:all => :model_cs_branch_binding},
        #ddt/backend/admin/sales_emails#index|create|new|destroy
        sales_emails: {:all => :model_sales_email},
        #ddt/backend/admin/agents#reset_password|index|create|new|edit|show|update|update|destroy
        agents: {:all => :model_agent},
        #ddt/backend/admin/agent_rels#index|create|new|edit|show|update|update|destroy
        agent_rels: {:all => :model_agent_rel},
        #ddt/backend/admin/agent_zones#index|create|new|edit|show|update|update|destroy
        agent_zones: {:all => :model_agent_zone},
        #ddt/backend/admin/lisences#index|create|new|edit|show|update|update|destroy
        lisences: {:all => :model_lisence},
        #ddt/backend/admin/agent_materials#index|create|new|edit|show|update|update|destroy
        agent_materials: {:all => :model_agent_material},
        #ddt/backend/admin/service_products#change_position|change_preferences|index|create|new|edit|show|update|update|destroy
        service_products: {:all => :model_service_product},
        #ddt/backend/service_product_orders#index|create|new|edit|show|update|update|destroy|pay_with_alipay|index|create|new|edit|show|update|update|destroy
        service_product_orders: {:all => :model_service_product_order},
        #ddt/backend/shops#crm|config_guide|welcome|home|feature_modules|export_accounts|dashboard|show_search_word|update_search_word|edit_search_word|module_index|copy_link|update_sale_employee|index|create|new|edit|show|update|update|destroy
        feature_modules_configs: {:all => :model_feature_modules_config},
        #ddt/backend/feature_modules_configs#index|create|new|edit|show|update|destroy
        shops: {:all => :model_shop},
        #ddt/backend/recharge_refunds#complete|cancel|index
        recharge_refunds: {:all => :model_recharge_refund},
        #ddt/backend/printers#index
        printers: {:all => :model_printer},
        #ddt/backend/credits_settings#edit|show|update|update
        credits_settings: {:all => :model_credits_setting},
        #ddt/backend/home_hot_links#change_position|index|create|new|edit|show|update|update|destroy
        home_hot_links: {:all => :model_home_hot_link},
        #ddt/backend/home_usable_links#change_position|index|create|new|edit|show|update|update|destroy
        home_usable_links: {:all => :model_home_usable_link},
        #ddt/backend/custom_weixin_infos#create|new|edit|show|update|update|destroy
        custom_weixin_infos: {:all => :model_custom_weixin_info},
        #ddt/backend/sign_records#index
        sign_records: {:all => :model_sign_record},
        #ddt/backend/shifts#print|index|show
        shifts: {:all => :model_shift},
        #ddt/backend/recharge_products#change_position|index|create|new|edit|show|update|update|destroy
        recharge_products: {:all => :model_recharge_product},
        #ddt/backend/exchange_codes#exchange|index
        exchange_codes: {:all => :model_exchange_code},
        #ddt/backend/email_settings#test|create|new|edit|show|update|update|destroy
        email_settings: {:all => :model_email_setting},
        #ddt/backend/one_pages#change_position|index|create|new|edit|show|update|update|destroy
        one_pages: {:all => :model_one_page},
        #ddt/backend/table_colors#create|new|edit|show|update|update|destroy
        table_colors: {:all => :model_table_color},
        #ddt/backend/test_consoles#valid_wechat_users|data_maker_panel|create|new|edit|show|update|update|destroy
        test_consoles: {:all => :model_test_console},
        #ddt/backend/statistic/user_statistics#new_user|user_access|recharge_record|consume_record|recharge_summary|consume_summary|card_log|card_summary|credits_summary
        user_statistics: {:all => :model_user_statistic},
        #ddt/backend/statistic/product_statistics#subtract|subtract_summary|gift_product|gift_summary|combo_summary|combo_product|product_summary|category_summary|product_contrast
        product_statistics: {:all => :model_product_statistic},
        #ddt/backend/statistic/business_statistics#pay_log|shift|sales_by_day|sales_by_week|sales_by_month|sales_by_year|sales_by_branch|flow_of_customer|promotion|recharge_settle_summary
        business_statistics: {:all => :model_business_statistic},
        #ddt/backend/statistic/coupon_statistics#coupon|coupon_summary|voucher|voucher_summary
        coupon_statistics: {:all => :model_coupon_statistic},
        #ddt/backend/statistic/orders_statistics#order_count_by_day|order_count_by_month|order_count_by_year|order_count_by_branch|order_origin|order_discount|change_log|change_log_detail
        orders_statistics: {:all => :model_orders_statistic},
        #ddt/backend/statistic/table_statistics#summary|rockover_rate_by_day|rockover_rate_by_week|rockover_rate_by_month|index|create|new|edit|show|update|update|destroy
        table_statistics: {:all => :model_table_statistic},
        #ddt/backend/statistic/worker_statistics#serve|serve_detail|delivery|index|create|new|edit|show|update|update|destroy
        worker_statistics: {:all => :model_worker_statistic},
        #ddt/backend/statistic/finance_statistics#combi_t1|combi_t2|order_detail|index|create|new|edit|show|update|update|destroy
        finance_statistics: {:all => :model_finance_statistic},
        #ddt/backend/statistics#new_user_by_month|new_user_by_year|wechat_user_by_month|wechat_user_by_year|wechat_user_by_gonghao|sale_value_by_month|sale_value_by_year|sale_amount_by_month|sale_amount_by_year|access_by_month|access_by_year|order_by_month|order_by_year|consume_sort_by_month|consume_sort_by_year
        statistics: {:all => :model_statistic},
        #ddt/backend/wechat_share_records#index|create|new|edit|show|update|update|destroy
        wechat_share_records: {:all => :model_wechat_share_record},
        #ddt/backend/materials#choose_material|index|create|new|edit|show|update|update|destroy
        materials: {:all => :model_material},
        #ddt/backend/articles#index|create|new|edit|show|update|update|destroy|index|create|new|edit|show|update|update|destroy
        articles: {:all => :model_article},
        #ddt/backend/events#index|create|new|edit|show|update|update|destroy
        events: {:all => :model_event},
        #ddt/backend/qrcode/base_qr_code_scenes#index|create|new|edit|show|update|update|destroy
        base_qr_code_scenes: {:all => :model_base_qr_code_scene},
        #ddt/backend/qrcode/wechat_qr_code_scenes#index|create|new|edit|show|update|update|destroy
        wechat_qr_code_scenes: {:all => :model_wechat_qr_code_scene},
        #ddt/backend/qrcode/qr_code_scenes#index|create|new|edit|show|update|update|destroy
        qr_code_scenes: {:all => :model_qr_code_scene},
        #ddt/backend/roles#index|create|new|edit|show|update|update|destroy
        roles: {:all => :model_role, [:show, :index] => :model_base_role},
        #ddt/backend/zones#index|create|new|edit|show|update|update|destroy
        zones: {:all => :model_zone},
        #ddt/backend/gift_reasons#change_position|index|create|new|edit|show|update|update|destroy
        gift_reasons: {:all => :model_gift_reason},
        #ddt/backend/subtract_reasons#change_position|index|create|new|edit|show|update|update|destroy
        subtract_reasons: {:all => :model_subtract_reason},
        #ddt/backend/branch_types#index_branch_nav|edit_branch_nav|update_branch_nav|index|create|new|edit|show|update|update|destroy
        branch_types: {:all => :model_branch_type},
        #ddt/backend/branch_groups#index|create|new|edit|show|update|update|destroy
        branch_groups: {:all => :model_branch_group},
        #ddt/backend/shop/event_promotion/promotion_rules#index|create|destroy
        promotion_rules: {:all => :model_promotion_rule},
        #ddt/backend/shop/event_promotion/promotion_actions#index|create|destroy
        promotion_actions: {:all => :model_promotion_action},
        #ddt/backend/shop/event_promotions#index|create|new|edit|show|update|update|destroy
        event_promotions: {:all => :model_event_promotion},
        #ddt/backend/shop/order_promotion/promotion_rules#index|create|destroy
        promotion_rules: {:all => :model_promotion_rule},
        #ddt/backend/shop/order_promotion/promotion_actions#index|create|destroy
        promotion_actions: {:all => :model_promotion_action},
        #ddt/backend/shop/order_promotions#index|create|new|edit|show|update|update|destroy
        order_promotions: {:all => :model_order_promotion},
        #ddt/backend/shop/pay_methods#change_position|index|create|new|edit|show|update|update|destroy
        pay_methods: {:all => :model_pay_method},
        #ddt/backend/shop/pay_method_settings#update_all|index
        pay_method_settings: {:all => :model_pay_method_setting},
        #ddt/backend/product/shop_variants#index
        shop_variants: {:all => :model_shop_variant},
        #ddt/backend/order/delivery_orders#assigned|index|get_assign|assign|start|ship|confirm|cancel|complete|other_msg|get_reprint|chooseable_printers|reprint|pay_by_default_method|get_append_pay_item|append_pay_item|show
        delivery_orders: {:all => :model_delivery_order},
        #ddt/backend/tags#index|create|new|edit|show|update|update|destroy|index|create|new|edit|show|update|update|destroy
        tags: {:all => :model_tag},
        #ddt/backend/branches#change_position|get_erase|erase_data|rollback_data|index|create|new|edit|show|update|update|destroy
        branches: {:all => :model_branch},
        #ddt/backend/item_notes#index|create|new|edit|show|update|update|destroy
        item_notes: {:all => :model_item_note},
        #ddt/backend/essential_products#index|create|new|edit|update|update|destroy
        essential_products: {:all => :model_essential_product},
        #ddt/backend/tag/product_tags#index|create|new|edit|show|update|update|destroy
        product_tags: {:all => :model_product_tag},
        #ddt/backend/tag/item_note_tags#index|create|new|edit|show|update|update|destroy
        item_note_tags: {:all => :model_item_note_tag},
        #ddt/backend/tag/branch_tags#index|create|new|edit|show|update|update|destroy
        branch_tags: {:all => :model_branch_tag},
        #ddt/backend/delivery_settings#create|new|edit|show|update|update|destroy
        delivery_settings: {:all => :model_delivery_setting},
        #ddt/backend/bill_template_settings#preview|reset|set_enable|edit|show|update|update
        bill_template_settings: {:all => :model_bill_template_setting},
        #ddt/backend/delivery_zones#index|create|new|edit|show|update|update|destroy
        delivery_zones: {:all => :model_delivery_zone},
        #ddt/backend/arranging_settings#create|new|edit|show|update|update|destroy
        arranging_settings: {:all => :model_arranging_setting},
        #ddt/backend/delivery_ranges#index|create|new|edit|show|update|update|destroy
        delivery_ranges: {:all => :model_delivery_range},
        #ddt/backend/waiter_service_items#index|create|new|edit|show|update|update|destroy
        waiter_service_items: {:all => :model_waiter_service_item},
        #ddt/backend/cooks#index|edit|update|update
        cooks: {:all => :model_cook},
        #ddt/backend/cs_branch_bindings#create|new|edit|show|update|update|destroy
        cs_branch_bindings: {:all => :model_cs_branch_binding},
        #ddt/backend/queue_settings#board|index|create|new|edit|show|update|update|destroy
        queue_settings: {:all => :model_queue_setting},
        #ddt/backend/guest_queues#pass|cancel|accept|notify|index|create|new|edit|show|update|update|destroy
        guest_queues: {:all => :model_guest_queue},
        #ddt/backend/reservation_settings#create|new|edit|show|update|update|destroy
        reservation_settings: {:all => :model_reservation_setting},
        #ddt/backend/eat_in_hall_settings#create|new|edit|show|update|update|destroy
        eat_in_hall_settings: {:all => :model_eat_in_hall_setting},
        #ddt/backend/order/reservation_orders#confirm|cancel|complete|other_msg|get_reprint|chooseable_printers|reprint|pay_by_default_method|get_append_pay_item|append_pay_item|show
        reservation_orders: {:all => :model_reservation_order},
        #ddt/backend/order/eat_in_hall_orders#confirm|cancel|complete|other_msg|get_reprint|chooseable_printers|reprint|pay_by_default_method|get_append_pay_item|append_pay_item|show
        eat_in_hall_orders: {:all => :model_eat_in_hall_order},
        #ddt/backend/order/fastfood_orders#confirm|cancel|complete|other_msg|get_reprint|chooseable_printers|reprint|pay_by_default_method|get_append_pay_item|append_pay_item|show
        fastfood_orders: {:all => :model_fastfood_order},
        #ddt/backend/order/groupon_orders#confirm|cancel|complete|other_msg|get_reprint|chooseable_printers|reprint|pay_by_default_method|get_append_pay_item|append_pay_item|show
        groupon_orders: {:all => :model_groupon_order},
        #ddt/backend/order/recharge_orders#confirm|cancel|complete|other_msg|get_reprint|chooseable_printers|reprint|pay_by_default_method|get_append_pay_item|append_pay_item|show
        recharge_orders: {:all => :model_recharge_order},
        #ddt/backend/order/payment_orders#confirm|cancel|complete|other_msg|get_reprint|chooseable_printers|reprint|pay_by_default_method|get_append_pay_item|append_pay_item|show
        payment_orders: {:all => :model_payment_order},
        #ddt/backend/product/products#import_products|import_failed|error_products|batch_remove|batch_on_shelf|batch_off_shelf|batch_estimate_clear|batch_estimate_full|batch_copy|copy|search|create_qrcode|change_position|index|create|new|edit|show|update|update|destroy
        products: {:all => :model_product},
        #ddt/backend/product/variant_images#list|add_exist_image|change_position|index|create|new|edit|show|update|update|destroy
        variant_images: {:all => :model_variant_image},
        #ddt/backend/product/combo_images#list|add_exist_image|change_position|index|create|new|edit|show|update|update|destroy
        combo_images: {:all => :model_combo_image},
        #ddt/backend/product/variants#add_estimate_clear|remove_estimate_clear|add_estimate_clear_reciprocal|ajax_estimate_clear_reciprocal|change_position|index|create|new|edit|show|update|update|destroy
        variants: {:all => :model_variant},
        #ddt/backend/product/option_types#change_position|index|create|new|edit|show|update|update|destroy
        option_types: {:all => :model_option_type},
        #ddt/backend/product/categories#products_actions|update_products|change_position|index|create|new|edit|show|update|update|destroy
        categories: {:all => :model_category},
        #ddt/backend/product/combos#post_batch_copy|get_batch_copy|change_position|index|create|new|edit|show|update|update|destroy
        combos: {:all => :model_combo},
        #ddt/backend/product/combo_items#change_position|index|create|new|edit|show|update|update|destroy
        combo_items: {:all => :model_combo_item},
        #ddt/backend/comments#reply|index|create|new|edit|show|update|update|destroy
        comments: {:all => :model_comment},
        #ddt/backend/branch/event_promotion/promotion_rules#index|create|new|edit|show|update|update|destroy
        promotion_rules: {:all => :model_promotion_rule},
        #ddt/backend/branch/event_promotion/promotion_actions#index|create|new|edit|show|update|update|destroy
        promotion_actions: {:all => :model_promotion_action},
        #ddt/backend/branch/event_promotions#index|create|new|edit|show|update|update|destroy
        event_promotions: {:all => :model_event_promotion},
        #ddt/backend/branch/order_promotion/promotion_rules#index|create|new|edit|show|update|update|destroy
        promotion_rules: {:all => :model_promotion_rule},
        #ddt/backend/branch/order_promotion/promotion_actions#index|create|new|edit|show|update|update|destroy
        promotion_actions: {:all => :model_promotion_action},
        #ddt/backend/branch/order_promotions#index|create|new|edit|show|update|update|destroy
        order_promotions: {:all => :model_order_promotion},
        #ddt/backend/branch/print_settings#create|new|edit|show|update|update|destroy
        print_settings: {:all => :model_print_setting},
        #ddt/backend/branch/printers#test_print|clear_records|toggle|get_state|products|index|create|new|edit|show|update|update|destroy
        printers: {:all => :model_printer},
        #ddt/backend/branch/print_records#index|create|new|edit|show|update|update|destroy
        print_records: {:all => :model_print_record},
        #ddt/backend/branch/pay_method_settings#update_all|index
        pay_method_settings: {:all => :model_pay_method_setting},
        #ddt/backend/sale_data_uploader_settings#upload_base|upload_orders|query_orders|reupload_orders|create|new|edit|show|update|update|destroy
        sale_data_uploader_settings: {:all => :model_sale_data_uploader_setting},
        #ddt/backend/kitchen_settings#create|new|edit|show|update|update|destroy
        kitchen_settings: {:all => :model_kitchen_setting},
        #ddt/backend/tick_account_items#complete|batch_complete|index
        tick_account_items: {:all => :model_tick_account_item},
        #ddt/backend/tick_accounts#index|create|new|edit|show|update|update|destroy
        tick_accounts: {:all => :model_tick_account},
        #ddt/backend/reservation_time_points#get_batch_create|post_batch_create|index|create|new|edit|show|update|update|destroy
        reservation_time_points: {:all => :model_reservation_time_point},
        #ddt/backend/discount_plans#index|create|new|edit|show|update|update|destroy
        discount_plans: {:all => :model_discount_plan},
        #ddt/backend/table_zones#index|create|new|edit|show|update|update|destroy
        table_zones: {:all => :model_table_zone},
        #ddt/backend/tables#get_order|new_bind|bind|unbind|enable_qr_code|disable_qr_code|regenerate_qr_code|get_export_list|export_all|get_batch_create|post_batch_create|index|create|new|edit|show|update|update|destroy
        tables: {:all => :model_table},
        #ddt/backend/form_elements#new_select|new_textarea|save_sequence|index|create|new|edit|show|update|update|destroy
        form_elements: {:all => :model_form_element},
        #ddt/backend/locations#index|index
        locations: {:all => :model_location},
        #ddt/backend/accounts#edit_password|update_password|get_bind|bind|unbind|index|create|new|edit|show|update|update|destroy|edit_password|update_password|get_bind|bind|unbind|index|create|new|edit|show|update|update|destroy
        accounts: {:all => :model_account},
        #ddt/backend/vip_levels#index|create|new|edit|show|update|update|destroy
        vip_levels: {:all => :model_vip_level},
        #ddt/backend/vip_infos#applying|get_bindable|remind_bind|import_vip_infos|import_failed|error_vip_infos|destroy_all|agree|reject|edit_pay_password|update_pay_password|index|create|new|edit|show|update|update|destroy
        vip_infos: {:all => :model_vip_info},
        #ddt/backend/vip_searches#compute|recompute|export|index|create|new|edit|show|update|update|destroy
        vip_searches: {:all => :model_vip_search},
        #ddt/backend/notification_receive_settings#edit|show|update|update
        notification_receive_settings: {:all => :model_notification_receive_setting},
        #ddt/backend/orders#export_selected|get_export_list|export_all|batch_change_state|batch_change_pay_item_state|anti_settlements|print|index|create|new|edit|show|update|update|destroy
        orders: {:all => :model_order},
        #ddt/backend/wallet/shop_card_wallets#branches|base_users|wallet_logs|create|new|edit|show|update|update|destroy
        shop_card_wallets: {:all => :model_shop_card_wallet},
        #ddt/backend/wallet/shop_credits_wallets#branches|base_users|wallet_logs|create|new|edit|show|update|update|destroy
        shop_credits_wallets: {:all => :model_shop_credits_wallet},
        #ddt/backend/wallet/branch_card_wallets#wallet_logs|get_clearing|clearing|index|create|new|edit|show|update|update|destroy
        branch_card_wallets: {:all => :model_branch_card_wallet},
        #ddt/backend/wallet/branch_credits_wallets#wallet_logs|get_clearing|clearing|index|create|new|edit|show|update|update|destroy
        branch_credits_wallets: {:all => :model_branch_credits_wallet},
        #ddt/backend/wallet/user_card_wallets#wallet_logs|get_exchange|exchange|get_recharge|recharge|index|create|new|edit|show|update|update|destroy
        user_card_wallets: {:all => :model_user_card_wallet},
        #ddt/backend/wallet/user_credits_wallets#wallet_logs|get_exchange|exchange|index|create|new|edit|show|update|update|destroy
        user_credits_wallets: {:all => :model_user_credits_wallet},
        #ddt/backend/wallet/collection_logs#index
        collection_logs: {:all => :model_collection_log},
        #ddt/backend/wallet/withdraws#index|create|new|edit|show|update|update|destroy
        withdraws: {:all => :model_withdraw},
        #ddt/backend/groupon_versions#choose_groupon_branch|index|create|new|edit|show|update|update|destroy
        groupon_versions: {:all => :model_groupon_version},
        #ddt/backend/voucher_versions#index|create|new|edit|show|update|update|destroy
        voucher_versions: {:all => :model_voucher_version},
        #ddt/backend/coupon_versions#index|create|new|edit|show|update|update|destroy
        coupon_versions: {:all => :model_coupon_version},
        #ddt/backend/groupons#refund|index|create|new|edit|show|update|update|destroy
        groupons: {:all => :model_groupon},
        #ddt/backend/vouchers#refund|index|create|new|edit|show|update|update|destroy
        vouchers: {:all => :model_voucher},
        #ddt/backend/coupons#index|create|new|edit|show|update|update|destroy
        coupons: {:all => :model_coupon},
        #ddt/backend/wechat_accounts#auto_config|wechat_users|component_auth|auto_config|index|create|new|edit|show|update|update|destroy
        wechat_accounts: {:all => :model_wechat_account},
        #ddt/backend/wechat_menus#sync|change_position|index|create|new|edit|show|update|update|destroy
        wechat_menus: {:all => :model_wechat_menu},
        #ddt/backend/keywords_third_party_interfaces#index|create|new|edit|show|update|update|destroy
        keywords_third_party_interfaces: {:all => :model_keywords_third_party_interface},
        #ddt/backend/shake_around/apply_logs#index|create|new|edit|show|update|update|destroy
        apply_logs: {:all => :model_apply_log},
        #ddt/backend/shake_around/devices#refresh|get_bind|bindable|bind|unbind|index|create|new|edit|show|update|update|destroy
        devices: {:all => :model_device},
        #ddt/backend/shake_around/shake_infos#index|create|new|edit|show|update|update|destroy|index|create|new|edit|show|update|update|destroy
        shake_infos: {:all => :model_shake_info},
        #ddt/backend/shake_around/pages#refresh|get_bind|bindable|bind|unbind|index|create|new|edit|show|update|update|destroy
        pages: {:all => :model_page},
        #ddt/backend/user/base_users#normal_users|vip_users|find_by_user_open_id|get_send_coupon|send_coupon|get_recharge_card_wallet|recharge_card_wallet|recharge_card_wallet|get_exchange_card_wallet|exchange_card_wallet|exchange_card_wallet|get_exchange_credits_wallet|exchange_credits_wallet|exchange_credits_wallet|card_wallet_logs|credits_wallet_logs|recharge_orders|index|create|new|edit|show|update|update|destroy
        base_users: {:all => :model_base_user},
        #ddt/backend/user/users#index|create|new|edit|show|update|update|destroy
        users: {:all => :model_user},
        #ddt/backend/user/web_users#index|create|new|edit|show|update|update|destroy
        web_users: {:all => :model_web_user},
        #ddt/backend/user/phone_users#index|create|new|edit|show|update|update|destroy
        phone_users: {:all => :model_phone_user},
        #ddt/backend/short_messages#index|create|new|edit|show|update|update|destroy
        short_messages: {:all => :model_short_message},
        #ddt/backend/order_calls#index
        order_calls: {:all => :model_order_call},
        #ddt/backend/user_wallets#card_wallets
        user_wallets: {:all => :model_user_wallet},
        #ddt/backend/payment/payments#index|create|new|edit|show|update|update|destroy
        payments: {:all => :model_payment},
        #ddt/backend/payment/payment_logs#index|create|new|edit|show|update|update|destroy
        payment_logs: {:all => :model_payment_log},
        #ddt/backend/payment/alipay_methods#gen_rsa|create|new|edit|show|update|update|destroy
        alipay_methods: {:all => :model_alipay_method},
        #ddt/backend/withdraw#create|new|edit|show|update|update|destroy
        withdraws: {:all => :model_withdraw},
        #ddt/backend/payment/wechatpay_method_legacies#switch_version|create|new|edit|show|update|update|destroy
        wechatpay_method_legacies: {:all => :model_wechatpay_method_legacy},
        #ddt/backend/payment/wechatpay_method_v336s#switch_version|create|new|edit|show|update|update|destroy
        wechatpay_method_v336s: {:all => :model_wechatpay_method_v336},
        #ddt/backend/payment/baidupay_methods#create|new|edit|show|update|update|destroy
        baidupay_methods: {:all => :model_baidupay_method},
        #ddt/backend/branch_sliders#change_position|index|create|new|edit|show|update|update|destroy
        branch_sliders: {:all => :model_branch_slider},
        #ddt/backend/admin/weixin_pages#index|create|new|edit|show|update|update|destroy
        weixin_pages: {:all => :model_weixin_page},
        #ddt/backend/merchant_applies#confirm|reject|index|show
        merchant_applies: {:all => :model_merchant_apply},
        #ddt/backend/service_products#index|create|new|edit|show|update|update|destroy
        service_products: {:all => :model_service_product},
        #ddt/backend/short_message_settings#edit|show|update|update
        short_message_settings: {:all => :model_short_message_setting},
        #ddt/backend/call_settings#edit|show|update|update
        call_settings: {:all => :model_call_setting},
        #ddt/backend/supplies#queue_qr_codes|export_queue_qr_code|door_stickers|export_door_sticker|fastfood_stickers|export_fastfood_sticker
        supplies: {:all => :model_supply},
        #ddt/backend/time_intervals#index|create|new|edit|show|update|update|destroy
        time_intervals: {:all => :model_time_interval},
        #ddt/backend/crm/vip_levels#index|create|new|edit|show|update|update|destroy
        vip_levels: {:all => :model_vip_level},
        #ddt/backend/crm/recharge_products#index|create|new|edit|show|update|update|destroy
        recharge_products: {:all => :model_recharge_product},
        #ddt/backend/crm/vip_info_settings#show|update|update
        vip_info_settings: {:all => :model_vip_info_setting},
        #ddt/backend/crm/credits_settings#show|update|update
        credits_settings: {:all => :model_credits_setting},
        #ddt/backend/crm/vip_infos#send_coupon|credits_clear|import|import_failed|batch_destroy|batch_agree_apply_vip|recharge_card_wallet|exchange_card_wallet|recharge_credits_wallet|agree_apply_vip|reject_apply_vip|block|orders|index|create|show|update|update
        vip_infos: {:all => :model_vip_info},
        #ddt/backend/crm/card_wallet_logs#index
        card_wallet_logs: {:all => :model_card_wallet_log},
        #ddt/backend/crm/credits_wallet_logs#index
        credits_wallet_logs: {:all => :model_credits_wallet_log},
        #ddt/backend/crm/coupon_photos#batch_destroy|index|create
        coupon_photos: {:all => :model_coupon_photo},
        #ddt/backend/crm/coupon_versions#index|create|new|edit|show|update|update|destroy
        coupon_versions: {:all => :model_coupon_version},
        #ddt/backend/crm/branches#index
        branches: {:all => :model_branch},
        #ddt/backend/crm/coupons#index
        coupons: {:all => :model_coupon},
        #ddt/backend/crm/shops#show
        shops: {:all => :model_shop},
      }.merge({
        branch_types: {
          [:index_branch_nav, :edit_branch_nav, :update_branch_nav] => :wechat_api,
          :all => :model_branch_type
        },
        products: {
          [:batch_copy, :copy] => :copy_product,
          :all => :model_product
        }
      })
    end




    end
  end
end
