#encoding: utf-8
module Ddt
  module Features
    ALL = {

      # Base
      model_ability:             '获取权限',
      model_session:             '登陆',
      model_registration:        '注册',
      model_password:            '密码找回',
      model_unlock:              '解锁账户',
      model_sms_captcha:         '验证码',
      model_email_setting:       '系统邮件设置',
      model_zone:                '区域',
      model_shop:                '系统设置',
      model_branch:              '门店设置',
      model_account:             '账户设置',
      model_role:                '角色',
      model_base_role:           '角色',
      model_table_zone:          '桌台区域',
      model_table:               '桌台设置',
      model_table_color:         '桌台颜色',
      model_pay_method:          '支付方式',
      model_pay_method_setting:  '支付方式设置',
      model_shop_variant:        '规格',
      model_category:            '产品分类',
      model_product:             '产品管理',
      model_variant:             '产品规格',
      model_asset_tag:           '资源标签',
      model_variant_image:       '规格图片',
      model_combo_image:         '套餐图片',
      model_option_type:         '规格',
      model_option_value:        '规格值',
      model_combo_package:       '套餐包',
      model_combo:               '套餐管理',
      model_combo_item:          '套餐小项',
      model_label:               '赠退菜标签',
      model_gift_reason:         '赠菜理由',
      model_subtract_reason:     '退菜原因',
      model_time_interval:       '时段设置',
      model_discount_plan:       '折扣方案',
      model_print_setting:       '打印设置',
      model_printer:             '打印机配置',
      model_printer_code:        '打印机授权码',
      model_print_record:        '打印纪录',
      model_shift:               '交接班',
      model_shift_log:           '交班记录',
      model_item_note:           '品注',
      model_product_tag:         '产品标签',
      model_item_note_tag:       '品注标签',
      model_order:               '订单管理',
      model_order_itemable:     '订单存区',
      model_line_item:           '订单条目',
      model_base_user:           '用户',
      model_user:                '微信用户',
      model_web_user:            '网站用户',
      model_phone_user:          '电话用户',
      model_payment_log:         '支付日志',
      model_pay_item:            '支付条目',
      model_collection_log:      '代收款',
      model_variant_package:     '称重产品',
      model_estimate_clear:      '沽清',
      model_notification_receive_setting: '消息设置',
      model_notification:        '通知消息',
      model_order_promotion:     '满减促销',
      model_promotion_rule:      '促销规则',
      model_promotion_action:    '促销动作',
      model_tag:                 '标签',
      model_bill_center:         '清单中心',
      model_feature_modules_config: '服务模块',
      model_form_element:        '自定义表单',


      # event promotion
      base_event_promotion:      '免赠促销',
      model_event_promotion:     '免赠促销',
      # base
      # wechat


      # base promotion
      base_promotion:            '基础优惠',
      model_coupon_version:      '优惠券版本',
      model_coupon_photo:        '优惠券图片',
      model_coupon:              '优惠券',
      model_sharable_coupon:     '优惠券红包',
      coupon_exchange:           '券核销',
      model_coupon_exchange:     '券核销',
      model_base_coupon:         '券核销',
      model_credits_setting:     '积分设置',
      model_credit:              '积分',
      model_credits_wallet:      '积分钱包',
      model_credits_wallet_log:  '用户积分日志',
      model_shop_credits_wallet: '平台积分钱包',
      model_branch_credits_wallet:'门店积分钱包',
      model_user_credits_wallet: '积分钱包',
      model_user_wallet:         '用户钱包',



      # Pay Base
      model_short_message_setting: '短信设置',
      model_short_message:        '短信',
      model_call_setting:        '短信设置',
      model_order_call:          '呼叫提醒',
      model_tick_account:        '挂账',
      model_tick_account_item:   '挂账条目',
      model_exchange_code:       '兑换码',
      model_alipay_method:       '支付宝',
      model_wechatpay_method_legacies: '微信支付老版本',
      model_wechatpay_method_legacy: '微信支付老版本',
      model_wechatpay_method_v336s: '微信支付V336s',
      model_wechatpay_method_v336: '微信支付V336s',
      model_baidupay_method: '百度支付',
      model_payments:        '交易流水',
      model_withdraw:        '代收款记录',


      # Wechat Base
      wechat_api:                '微信模块',
      model_custom_weixin_info:  '微信自定义消息',
      model_wechat_home_template:'微信首页模板',
      model_one_page:            '开机动画',
      model_branch_type_icon:    '门店分类图标',
      model_home_hot_link:       '首页导航按钮',
      model_home_usable_link:    '首页实用链接',
      model_essential_product:   '必选产品',
      model_wechat_pay_method:   '微信端付款方式',
      model_branch_slider:       '首页幻灯片',
      model_weixin_page:         '自定义会员模板',
      model_qr_code_manage:      '二维码物料管理',
      model_link_factory:        '链接工厂',
      model_merchant_apply:      '入驻加盟',
      model_wechat_share:        '分享朋友圈',
      model_wechat_share_record: '微信分享记录',
      model_material:            '素材',
      model_article:             '文章',
      model_event:               '自动回复',
      model_qr_code:             '会员识别',
      model_base_qr_code_scene:  '普通二维码',
      model_qr_code_scene:       '二维码',
      model_wechat_qr_code_scene:'微信二维码',
      model_promotion:           '促销活动',
      model_waiter_service_item: '微信服务项',
      model_favorite_branch:     '收藏门店',
      model_sign_record:         '签到',
      model_bind_order:          '绑定订单',
      model_comment:             '评论',
      model_order_comment:       '评论',
      model_wechat_account:      '公众号设置',
      model_wechat_menu:         '微信菜单',
      model_keywords_third_party_interface: '关键词转第三方',
      model_apply_log:           '摇一摇申请记录',
      model_device:              '摇一摇设备',
      model_page:                '摇一摇页面',
      model_shake_info:          '摇一摇日志',
      model_supply:              '物料',
      model_merchat_apply:       '申请入驻',
      model_censor_report:       '举报',
      model_invoice:             '发票',

      # Vip
      model_vip_info_setting:    '会员设置',
      model_vip_level:           '会员等级',
      model_vip_info:            '会员',
      model_vip_search:          '会员搜索',
      model_vip_crm:             '会员CRM',
      model_recharge_setting:    '充值设置',
      model_recharge:            '充值',
      model_recharge_product:    '充值产品',
      model_temp_recharge_product:'临时充值产品',
      model_recharge_order:      '充值订单',
      model_recharge_cart:       '充值购物车',
      model_recharge_log:        '充值记录',
      model_recharge_refund:     '充值退款',

      model_shop_card_wallet:    '平台储值钱包',
      model_branch_card_wallet:  '门店储值钱包',
      model_user_card_wallet:    '用户储值钱包',
      model_card_wallet_log:     '储值日志',


      # Queue
      base_queue:                '排号',
      model_queue:               '排队',
      model_queue_setting:       '队列设置',
      model_arranging_setting:   '排号设置',
      model_guest_queue:         '排号',
      queue_on_wechat:           '微信排号',
      queue_on_pad:              '平板排号',
      queue_on_pc:               '电脑排号',
      queue_pre_order:           '排号预点菜',

      # Statistic
      model_statistic:           '统计',
      model_user_statistic:      '用户分析',
      model_product_statistic:   '菜品分析',
      model_business_statistic:  '营业分析',
      model_coupon_statistic:    '发券分析',
      model_orders_statistic:    '订单分析',
      model_table_statistic:     '桌台分析',
      model_worker_statistic:    '工作分析',
      model_finance_statistic:   '财务分析',


      # eat_in_hall
      base_eat_in_hall:             '收银端堂点',
      model_eat_in_hall:            '收银端',
      model_eat_in_hall_cart:       '堂点购物车',
      model_eat_in_hall_setting:    '堂点设置',
      model_eat_in_hall_order:      '堂点订单',
      # wechat eat_in_hall
      eat_in_hall_on_wechat:        '扫码堂点',


      # delivery
      base_delivery:                '外卖基础',
      model_location:               '店员位置',
      model_delivery:               '外送',
      model_delivery_cart:          '外送购物车',
      model_delivery_order:         '外送订单',
      model_delivery_setting:       '外送设置',
      model_shipment:               '配送功能',
      model_delivery_zone:          '配送区域',
      model_delivery_range:         '配送范围',
      model_delivery_man:           '配送员',
      model_delivery_date:          '配送日期',
      model_delivery_time:          '配送时间',
      model_address:                '送货地址',
      # wechat delivery
      delivery_on_wechat:           '微信外卖',
      model_deliveryman_order:      '配送员订单',


      # fastfood
      base_fastfood:                '快餐基础',
      model_fastfood:               '快餐',
      model_fastfood_order:         '快餐订单',
      model_fastfood_cart:          '快餐购物车',
      # wechat fastfood
      fastfood_on_wechat:           '扫码快餐',

      # payment
      model_payment:                '买单基础',
      payment_on_app:               'App买单',
      model_payment_order:          '买单订单',
      # wechat payment
      payment_on_wechat:            '微信买单',

      # wechat groupon
      base_groupon:                 '团购基础',
      groupon_on_wechat:            '微信团购',
      model_tuan:                   '微信团购',
      model_groupon_order:          '团购订单',
      model_groupon_cart:           '团购购物车',
      model_groupon_version:        '团购券版本',
      model_voucher_version:        '代金券版本',
      model_groupon:                '团购券',
      model_voucher:                '代金券',

      # reservation
      base_reservation:             '预定基础',
      model_reservation:            '预定',
      model_reservation_cart:       '预定购物车',
      model_invitation_order:       '预定邀请函',
      model_reservation_setting:    '预定设置',
      model_reservation_order:      '预定订单',
      model_reservation_time_point: '预定时间段',
      model_reservation_info:       '预定信息',
      # wechat reservation
      reservation_on_wechat:        '微信预订',


      # sdu
      data_attach:         '物业数据对接',
      model_sale_data_uploader_setting: '销售数据物业对接设置',

      # cs
      offline_webpos:      '离线点餐系统',
      model_cs_branch_binding: 'CS',

      # custom bill template
      model_bill_template_setting: '自定义打印模板',

      # oem
      oem:                 'OEM模板',

      # pad
      pad_api:             'PAD点餐平板点餐',

      # app
      app_api:             '卖家助手App',

      # kitchen
      kitchen_api:         '厨显系统',
      model_kitchen_setting: '厨师设置',
      model_kitchen:       '厨师',
      model_litp:          '厨房菜品',
      model_cook:          '厨师配置',

      # wms
      wms_api:             '进销存数据对接',



      # MultiBranch And ChainBranch
      multi_branch:              '多门店管理',
      model_branch_zone:         '门店区域',
      model_branch_type:         '门店分类',
      model_branch_group:        '门店分组',
      model_branch_tag:          '门店标签',
      model_search_work:         '搜索关键词设置',
      copy_product:              '产品复制'

    }.with_indifferent_access

    class << self
      def all
        ALL
      end

      def get(key)
        ALL.fetch(key)
      end
    end
  end
end
