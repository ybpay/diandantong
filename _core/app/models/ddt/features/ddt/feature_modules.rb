#encoding: utf-8
module Ddt
  module FeatureModules
    # TODO: add more modules
    WHITE_LIST_FEATURES=[:model_ability, :model_session, :model_registration, :model_password, :model_unlock, :model_sms_captcha, :model_shop]
    @@ins = {

      base: {
        label: '系统基础功能',
        features: [
          # Base
          :model_email_setting,
          :model_zone,
          :model_branch,
          :model_account,
          :model_role,
          :model_base_role,
          :model_table_zone,
          :model_table,
          :model_table_color,
          :model_pay_method,
          :model_pay_method_setting,
          :model_shop_variant,
          :model_category,
          :model_product,
          :model_asset_tag,
          :model_variant,
          :model_variant_image,
          :model_combo_image,
          :model_option_type,
          :model_option_value,
          :model_combo_package,
          :model_combo,
          :model_combo_item,
          :model_label,
          :model_gift_reason,
          :model_subtract_reason,
          :model_time_interval,
          :model_discount_plan,
          :model_print_setting,
          :model_printer,
          :model_print_record,
          :model_shift,
          :model_shift_log,
          :model_item_note,
          :model_product_tag,
          :model_item_note_tag,
          :model_order,
          :model_order_itemable,
          :model_line_item,
          :model_base_user,
          :model_user,
          :model_web_user,
          :model_phone_user,
          :model_payment_log,
          :model_pay_item,
          :model_collection_log,
          :model_variant_package,
          :model_estimate_clear,
          :model_notification_receive_setting,
          :model_notification,
          :model_order_promotion,
          :model_promotion_rule,
          :model_promotion_action,
          :model_tag,
          :model_bill_center,
          :model_feature_modules_config,
          :model_form_element,
        ] + WHITE_LIST_FEATURES
      },


      pay_base: {
        label: '付费基础功能',
        features: [
          :model_short_message_setting,
          :model_short_message,
          :model_call_setting,
          :model_order_call,
          :model_tick_account,
          :model_tick_account_item,
          :model_exchange_code,
          :model_wechatpay_method_legacies,
          :model_wechatpay_method_legacy,
          :model_wechatpay_method_v336s,
          :model_wechatpay_method_v336,
          :model_baidupay_method,
          :model_alipay_method,
          :model_withdraw,
          :model_payments,
        ]
      },

      wechat_base: {
        label: '微信基础功能',
        features: [
          :wechat_api,
          :model_custom_weixin_info,
          :model_wechat_home_template,
          :model_one_page,
          :model_branch_type_icon,
          :model_home_hot_link,
          :model_home_usable_link,
          :model_essential_product,
          :model_wechat_pay_method,
          :model_branch_slider,
          :model_weixin_page,
          :model_qr_code_manage,
          :model_link_factory,
          :model_merchant_apply,
          :model_wechat_share,
          :model_wechat_share_record,
          :model_material,
          :model_article,
          :model_event,
          :model_qr_code,
          :model_base_qr_code_scene,
          :model_qr_code_scene,
          :model_wechat_qr_code_scene,
          :model_promotion,
          :model_waiter_service_item,
          :model_favorite_branch,
          :model_sign_record,
          :model_bind_order,
          :model_comment,
          :model_order_comment,
          :model_wechat_account,
          :model_wechat_menu,
          :model_keywords_third_party_interface,
          :model_apply_log,
          :model_device,
          :model_page,
          :model_shake_info,
          :model_supply,
          :model_merchat_apply,
          :model_censor_report,
          :model_invoice
        ]
      },

      vip: {
        label: '会员模块',
        features: [
          :model_vip_info_setting,
          :model_vip_level,
          :model_vip_info,
          :model_vip_search,
          :model_vip_crm,
          :model_recharge_setting,
          :model_recharge,
          :model_recharge_product,
          :model_temp_recharge_product,
          :model_recharge_order,
          :model_recharge_cart,
          :model_recharge_log,
          :model_recharge_refund,
          :model_shop_card_wallet,
          :model_branch_card_wallet,
          :model_user_card_wallet,
          :model_card_wallet_log
        ]
      },

      queue: {
        label: '排号模块',
        features: [
          :base_queue,
          :model_queue,
          :model_queue_setting,
          :model_arranging_setting,
          :model_guest_queue,
          :queue_on_wechat,
          :queue_on_pad,
          :queue_on_pc,
          :queue_pre_order
        ]
      },

      statistic: {
        label: '统计模块',
        features: [
          :model_statistic,
          :modle_statistics_cache,
          :model_user_statistic,
          :model_product_statistic,
          :model_business_statistic,
          :model_coupon_statistic,
          :model_orders_statistic,
          :model_table_statistic,
          :model_worker_statistic,
          :model_finance_statistic
        ]
      },

      eat_in_hall: {
        label: '堂点',
        features: [
          :base_eat_in_hall,
          :model_eat_in_hall,
          :model_eat_in_hall_cart,
          :model_eat_in_hall_setting,
          :model_eat_in_hall_order
        ]
      },

      eat_in_hall_on_wechat: {
        label: '扫码堂点',
        features: [
          :eat_in_hall_on_wechat
        ]
      },

      delivery: {
        label: '外卖',
        features: [
          :base_delivery,
          :model_location,
          :model_delivery,
          :model_delivery_cart,
          :model_delivery_order,
          :model_delivery_setting,
          :model_shipment,
          :model_delivery_zone,
          :model_delivery_range,
          :model_delivery_man,
          :model_delivery_date,
          :model_delivery_time,
          :model_address,
        ]
      },

      delivery_on_wechat: {
        label: '微信外卖',
        features: [
          :delivery_on_wechat,
          :model_deliveryman_order
        ]
      },

      fastfood: {
        label: '快餐',
        features: [
          :base_fastfood,
          :model_fastfood,
          :model_fastfood_order,
          :model_fastfood_cart
        ]
      },

      fastfood_on_wechat: {
        label: '扫码快餐',
        features: [
          :fastfood_on_wechat
        ]
      },

      reservation: {
        label: '预订',
        features: [
          :base_reservation,
          :model_reservation,
          :model_reservation_cart,
          :model_invitation_order,
          :model_reservation_setting,
          :model_reservation_order,
          :model_reservation_time_point,
          :model_reservation_info
        ]
      },

      reservation_on_wechat: {
        label: '微信预定',
        features: [
          :reservation_on_wechat
        ]
      },

      payment: {
        label: '闪惠买单',
        features: [
          :model_payment,
          :payment_on_app,
          :model_payment_order
        ]
      },

      payment_on_wechat: {
        label: '微信买单',
        sellable: false,
        features: [
          :payment_on_wechat
        ]
      },

      groupon: {
        label: '团购',
        features: [
          :base_groupon,
          :groupon_on_wechat,
          :model_tuan,
          :model_groupon_order,
          :model_groupon_cart,
          :model_groupon_version,
          :model_voucher_version,
          :model_groupon,
          :model_voucher
        ]
      },


      sdu: {
        label: '销售数据上传',
        features: [
          :data_attach,
          :model_sale_data_uploader_setting
        ]
      },


      cs: {
        label: '离线版收银',
        features: [
          :offline_webpos,
          :model_cs_branch_binding
        ]
      },


      bill_template: {
        label: '自定义打印模版',
        features: [
          :model_bill_template_setting
        ]
      },

      oem: {
        label: '品牌OEM',
        features: [
          :oem
        ]
      },


      pad: {
        label: 'PAD点餐',
        features: [
          :pad_api
        ]
      },

      app: {
        label: '点单通卖家助手',
        features: [
          :app_api
        ]
      },

      kitchen: {
        label: '厨显',
        features: [
          :kitchen_api,
          :model_kitchen_setting,
          :model_kitchen,
          :model_litp,
          :model_cook
        ]
      },

      wms: {
        label: '进销存',
        features: [
          :wms_api
        ]
      },

      chain: {
        label: '连锁店管理',
        features: [
          :multi_branch,
          :model_branch_zone,
          :model_branch_type,
          :model_branch_group,
          :model_branch_tag,
          :model_search_work,
          :copy_product
        ]
      },

      business_circle: {
        label: '本地生活商圈',
        features: [
          :multi_branch,
          :model_branch_zone,
          :model_branch_type,
          :model_branch_group,
          :model_branch_tag,
          :model_search_work,
        ]
      },

      event_promotion: {
        label: '免赠促销',
        features: [
          :base_event_promotion,
          :model_event_promotion
        ]
      },

      coupon: {
        label: '基础优惠',
        features: [
          :base_promotion,
          :model_coupon_version,
          :model_coupon_photo,
          :model_coupon,

          :coupon_exchange,
          :model_coupon_exchange,
          :model_base_coupon,
          :model_credits_setting,
          :model_credit,
          :model_credits_wallet,
          :model_credits_wallet_log,
          :model_shop_credits_wallet,
          :model_branch_credits_wallet,
          :model_user_credits_wallet,
          :model_user_wallet
        ]
      },

      reject: {
        label: '功能废除',
        features: [
          :model_sharable_coupon, # 微信不支持
        ]
      }

    }.with_indifferent_access

    @@ins.each do |k, m|
      m[:name] = k
      m[:features] = Set.new(m[:features])
    end


    def self.all
      @@ins
    end

    def self.feature_modules_name(feature_modules)
      @@ins.fetch(feature_modules)[:label]
    end

    def self.get(key)
      @@ins.fetch(key)
    end

    def self.module_name(key)
      match = @@ins.detect do |k, m|
        m[:features].include?(key)
      end
      match.present? ? match[1][:label] : 'unknow'
    end

    def self.has_feature?(modules, key)
      modules.any? do |it|
        m = @@ins[it]
        m[:features].include?(key) if m.present?
      end
    end

    def self.features(modules)
      fs = Set.new
      modules.each do |it|
        m = @@ins[it]
        fs.merge(m[:features])
      end
      fs
    end

    def self.select_json()
      @@ins.map {|name, entry| {
          id: name,
          name: entry[:label]
      }}
    end



  end
end
