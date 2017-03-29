module Ddt
  module Backend
    class Sidebar
      include ActionView::Helpers::TagHelper
      attr_accessor :output_buffer, :view, :account, :current_shop, :current_branch

      MENU_GROUPS = [
        :base,
        :wechat_base,
        :kitchen,
        :statistic,
        :bill_template,
        :eat_in_hall,
        :delivery,
        :fastfood,
        :reservation,
        :eat_in_hall_on_wechat,
        :delivery_on_wechat,
        :fastfood_on_wechat,
        :reservation_on_wechat,
        :groupon,
        :queue,
        :sdu,
        :cs,
        :chain,
        :business_circle
      ]

        # menu: {:name, :icon, :path_array, :permitted, :expired, sub_menus: []}

        # active: 当前激活的菜单, 根据当前 view.controller_name 来自动决定
        # expired: 是指平台对应模块是否过期,或不包含对应模块
        #   实际使用中,以下两个只需要配置其一即可。如果没有定义,说明所有平台都可以使用该模块
        #   modules: 如果包含了其中一个模块, 就允许启用
        #   features: 如果包含了其中一个功能点,就允许启用

        # permitted: 当前帐户有没有访问模块的权限
        #   permission: 需要的权限, 以 [scope, target, action] 的形式表达, 未设置表示所有人可以使用


      def dashboard
        menu_conf = []
        menu_conf << { name: '控制面板', icon: 'gear', features: [:model_shop], permission: [:shop, :shop, :dashboard], path_array: shop_scope(nil).unshift(:dashboard)}
        @menus.concat menu_conf
      end


      def base
        menu_conf = []
        menu_conf << { name: '订单中心', icon: 'gear',
          sub_menus: [
              {name: '订单列表', icon: 'dashboard', features: [:model_order], permission: [:branch, :order, :show], path_array: shop_scope(:orders)},
              {name: '反结账单', icon: 'dashboard', features: [:model_order], permission: [:branch, :order, :show], path_array: shop_scope(:orders).unshift(:anti_settlements)}
            ]
        }
        menu_conf << { name: '指派中心', icon: 'gear',
          sub_menus: [
              {name: '未指派', icon: 'dashboard', features: [:model_delivery], permission: [:branch, :order, :show], path_array: shop_scope(:delivery_orders)},
              {name: '已指派', icon: 'dashboard', features: [:model_delivery], permission: [:branch, :order, :show], path_array: shop_scope(:delivery_orders).unshift(:assigned)}
            ]
        }
        menu_conf << { name: '门店中心', icon: 'gear',
          sub_menus: [
              {name: '门店列表', icon: 'dashboard', features: [:model_branch], permission: [:shop, :branch, :update], path_array: shop_scope(:branches)},
              {name: '交班记录', icon: 'dashboard', features: [:model_shift], permission: [:branch, :shift, :show], path_array: shop_scope(:shifts)}
            ]
        }
        menu_conf << { name: '产品中心', icon: 'gear',
          sub_menus: [
              {name: '商品分类', icon: 'dashboard', features: [:model_category], permission: [:branch, :category, :create], path_array: branch_scope(:categories)},
              {name: '产品管理', icon: 'gear',      features: [:model_product], permission: [:branch, :product, :create], path_array: branch_scope(:products)},
              {name: '产品规格', icon: 'dashboard', features: [:model_option_type], permission: [:branch, :option_type, :create], path_array: branch_scope(:option_types)},
              {name: '套餐管理', icon: 'dashboard', features: [:model_combo], permission: [:branch, :combo, :create], path_array: branch_scope(:combos)},
              {name: '必选产品', icon: 'dashboard', features: [:model_essential_product], permission: [:branch, :essential_product, :create], path_array: branch_scope(:essential_products)},
              {name: '产品备注', icon: 'dashboard', features: [:model_item_note], permission: [:branch, :item_note, :create], path_array: branch_scope(:item_notes)},
              {name: '产品标签', icon: 'dashboard', features: [:model_tag], permissions: [:branch, :tag, :show], path_array: branch_scope(:tags)},
              {name: '自定义表单',icon:'dashboard', features: [:model_form_element], permission: [:branch, :form_element, :show], path_array: branch_scope(:form_elements)},
            ]
        }
        menu_conf << { name: '打印中心', icon: 'gear',
          sub_menus: [
              {name: '打印机授权码', icon: 'dashboard', features: [:model_printer_code], permission: [:shop, :printer_code, :update], path_array: shop_scope(:printer_codes)},
              {name: '打印设置', icon: 'dashboard', permission: [:branch, :order, :reprint], features: [:model_print_setting], permission: [:branch, :print_setting, :update], path_array: branch_scope(:print_setting)},
              {name: '配打印机', icon: 'dashboard', permission: [:branch, :order, :reprint], features: [:model_printer], permission: [:branch, :printer, :update], path_array: branch_scope(:printers)},
              {name: '打印档口', icon: 'dashboard', permission: [:branch, :order, :reprint], features: [:model_printer], permission: [:branch, :printer, :update], path_array: branch_scope(:printers).unshift(:products)},
              {name: '打印模板', icon: 'dashboard', features: [:model_bill_template_setting], permission: [:branch, :bill_template_setting, :update], path_array: branch_scope(:bill_template_setting)}
            ]
        }
        menu_conf << { name: '收银中心', icon: 'gear',
          sub_menus: [
              {name: '满减优惠', icon: 'dashboard', features: [:model_order_promotion], permission: [:shop, :order_promotion, :show], path_array: branch_scope(:order_promotions)},
              {name: '桌台分类', icon: 'dashboard', features: [:model_table_zone], permission: [:branch, :table_zone, :create], path_array: branch_scope(:table_zones)},
              {name: '桌台管理', icon: 'dashboard', features: [:model_table], permission: [:branch, :table, :create], path_array: branch_scope(:tables)},
              {name: '桌台颜色', icon: 'dashboard', features: [:model_table_color], permission: [:shop, :custom_setting, :show], path_array: shop_scope(:table_color)},
              {name: '时段配置', icon: 'dashboard', features: [:model_time_interval], permission: [:shop, :shop, :update], path_array: shop_scope(:time_intervals)},
              {name: '赠菜原因', icon: 'dashboard', features: [:model_gift_reason], permission: [:shop, :gift_reason, :create], path_array: shop_scope(:gift_reasons)},
              {name: '退菜原因', icon: 'dashboard', features: [:model_subtract_reason], permission: [:shop, :subtract_reason, :create], path_array: shop_scope(:subtract_reasons)},
              {name: '支付方式', icon: 'dashboard', features: [:model_pay_method], permission: [:shop, :pay_method, :show], path_array: shop_scope(:pay_methods)},
              {name: '支付配置', icon: 'dashboard', features: [:model_pay_method_setting], permission: [:shop, :pay_method, :update], path_array: shop_scope(:pay_method_settings)},
              {name: '挂账单位', icon: 'dashboard', features: [:model_tick_account], permission: [:branch, :tick_account, :create], path_array: branch_scope(:tick_accounts)},
            ]
        }
        menu_conf << { name: '支付模块', icon: 'gear',
          sub_menus: [
              {name: '自助支付配置', icon: 'dashboard', features: [:model_pay_method_setting], permission: [:branch, :pay_method, :update], path_array: branch_scope(:pay_method_settings)},
              {name: '支付宝 ',  icon: 'dashboard', features: [:model_alipay_method], permission: [:shop, :pay_method, :update], path_array: shop_scope(:alipay_methods)},
              {name: '微信支付', icon: 'dashboard', features: [:model_wechatpay_method_v336s], permission: [:shop, :pay_method, :update], path_array: shop_scope(:wechatpay_method_v336s)},
              {name: '百度钱包', icon: 'dashboard', features: [:model_baidupay_method], permission: [:shop, :pay_method, :update], path_array: shop_scope(:baidupay_methods)},
              {name: '交易流水', icon: 'dashboard', features: [:model_payments], permission: [:shop, :payment, :show], path_array: shop_scope(:payments)},
              {name: '余额管理', icon: 'dashboard', features: [:model_shop_card_wallet], permission: [:shop, :card_wallet, :manage], path_array: shop_scope(:shop_card_wallet).unshift(:branches)},
              {name: '充值退款', icon: 'dashboard', features: [:model_recharge_refund], permission: [:shop, :recharge_refund, :show], path_array: shop_scope(:recharge_refunds)},
            ]
        }
        menu_conf << { name: '系统中心', icon: 'gear',
          sub_menus: [
              {name: '系统设置', icon: 'dashboard', features: [:model_shop], permission: [:shop, :shop, :show], path_array: shop_scope(nil)},
              {name: '角色设置', icon: 'dashboard', features: [:model_role], permission: [:shop, :role, :create], path_array: shop_scope(:roles)},
              {name: '账号设置', icon: 'dashboard', features: [:model_account], permission: [:shop, :account, :show], path_array: shop_scope(:accounts)},
              {name: '服务模块', icon: 'dashboard', features: [:model_feature_modules_config], permission: [:shop, :feature_modules_config, :show], path_array: shop_scope(:feature_modules_configs)},

            ]
        }
        if account && account.is_admin?
          if @current_shop.present?
            menu_conf.last[:sub_menus].concat([
              {name: @current_shop.name.to_s + '充值记录', icon: 'dashboard', path_array: admin_scope(@current_shop).push(:shop_recharge_records)},
              {name: @current_shop.name.to_s + '定制微信页面', icon: 'dashboard', path_array: admin_scope(@current_shop).push(:weixin_pages)},
              ])
            if @current_branch.present?
              menu_conf.last[:sub_menus].concat([
                {name: @current_branch.name.to_s + '清除数据', icon: 'dashboard', path_array: branch_scope(nil).unshift(:get_erase)},
              ])
            end
          end
        end

        menu_conf << { name: '其它', icon: 'gear',
          sub_menus: [
              {name: '短信设置', icon: 'dashboard', features: [:model_short_message_setting], permission: [:shop, :short_message_setting, :update], path_array: shop_scope(:short_message_setting)},
              {name: '呼叫设置', icon: 'dashboard', features: [:model_call_setting], permission: [:shop, :short_message_setting, :update], path_array: shop_scope(:call_setting)}
            ]
        }
        @menus.concat menu_conf
      end

      def admin_bar
          menu_conf = []
          menu_conf << { name: '平台系统' , icon: 'gear',
            sub_menus: [
                {name: '客户账号',      icon: 'dashboard', path_array: admin_scope(:shops)},
                {name: '第三方授权应用',      icon: 'dashboard', path_array: admin_scope(:api_keys)},
                {name: 'Sidekiq',      icon: 'rocket', path_array: admin_scope(:sidekiq_web)},
                {name: 'JS异常',      icon: 'dashboard', path_array: admin_scope(:js_errors)},
                {name: '举报',        icon: 'dashboard', path_array: admin_scope(:censor_reports)},
                {name: '提款',        icon: 'dashboard', path_array: admin_scope(:withdraws)},
                # {name: '每天一笑',     icon: 'dashboard', path_array: admin_scope(:jokes)},
                {name: '统计报表',     icon: 'dashboard', path_array: admin_scope(:admin_statistics)},
                {name: 'App版本',     icon: 'dashboard', path_array: admin_scope(:app_versions)},
                {name: '售后人员',     icon: 'dashboard', path_array: admin_scope(:sale_employees)},
                {name: '售前人员',     icon: 'dashboard', path_array: admin_scope(:pre_sale_staffs)},
                {name: '产品图片资源',     icon: 'dashboard', path_array: admin_scope(:variant_images)},
                {name: '套餐图片资源',     icon: 'dashboard', path_array: admin_scope(:combo_images)},
                {name: '短信',    icon: 'dashboard', path_array: admin_scope(:short_messages)},
                {name: '短信验证码',    icon: 'dashboard', path_array: admin_scope(:sms_captchas)},
                {name: '注册表单', icon: 'dashboard', path_array: admin_scope(:register_forms)},
                {name: '第三方应用登录', icon: 'dashboard', path_array: "/oauth/applications"},
                {name: '销售邮件组',    icon: 'dashboard', path_array: admin_scope(:sales_emails)},
                {name: '批量二维码',  icon: 'dashboard', path_array: admin_scope(:qr_code_scenes)},
                {name: '二维码分配日志',  icon: 'dashboard', path_array: admin_scope(:qr_code_assign_logs)},
                {name: '账户充值记录', icon: 'dashboard', path_array: admin_scope(:shop_recharge_records)},
                {name: '门店CS服务', icon: 'dashboard', path_array: admin_scope(:cs_branch_bindings)},
              ]
          }

          menu_conf << { name: '代理', icon: 'gear',
            sub_menus: [
                {name: '代理商', icon: 'dashboard', path_array: admin_scope(:agents)},
                {name: '代理区域', icon: 'dashboard', path_array: admin_scope(:agent_zones)},
                {name: '授权许可', icon: 'dashboard', path_array: admin_scope(:lisences)},
                {name: '代理资料', icon: 'dashboard', path_array: admin_scope(:agent_materials)},
              ]
          }
          if @current_shop.blank?
            menu_conf << { name: '服务中心', icon: 'gear',
              sub_menus: [
                  {name: '服务套餐', icon: 'dashboard', path_array: admin_scope(:service_products)},
                  {name: '服务套餐订单', icon: 'dashboard', path_array: admin_scope(:service_product_orders)},
                ]
            }
          end
          @menus.concat menu_conf
      end

      def wechat_base
        menu_conf = []
        menu_conf << { name: '微信授权', icon: 'gear',
          sub_menus: [
              {name: '公众账号', icon: 'dashboard', features: [:model_wechat_account], permission: [:shop, :wechat_account, :manage], path_array: shop_scope(:wechat_accounts)},
              {name: '素材配置', icon: 'dashboard', features: [:model_material], permission: [:shop, :wechat_account, :manage], path_array: shop_scope(:materials)},
              {name: '自动回复', icon: 'dashboard', features: [:model_event], permission: [:shop, :wechat_account, :manage], path_array: shop_scope(:events)},
              {name: '文章管理', icon: 'dashboard', features: [:model_article], permission: [:shop, :wechat_account, :manage], path_array: shop_scope(:articles)},
              {name: '二维码  ', icon: 'dashboard', features: [:model_base_qr_code_scene], permission: [:shop, :qrcode, :show], path_array: shop_scope(:base_qr_code_scenes)}
            ]
        }
        menu_conf << { name: '微信餐厅', icon: 'gear',
          sub_menus: [
              {name: '门店图标', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types).unshift(:index_branch_nav)},
              {name: '首页模板', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).unshift(:edit)},
              {name: '开机动画', icon: 'dashboard', features: [:model_one_page], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:one_pages)},
              {name: '微信自定义界面', icon: 'dashboard', features: [:model_weixin_page], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:weixin_pages)},
              {name: '首页幻灯片', icon: 'dashboard', features:[:model_branch_slider], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:branch_sliders)},
              {name: '导航链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_hot_links)},
              {name: '实用链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_usable_links)},
              {name: '链接工厂', icon: 'dashboard', features: [:weixin_api], permission: [:shop, :wechat_config, :update], path_array: shop_scope(nil).unshift(:copy_link)},
              {name: '餐厅服务', icon: 'dashboard', features: [:model_waiter_service_item], permission: [:branch, :waiter_service_item, :show], path_array: branch_scope(:waiter_service_items)},
            ]
        }
        menu_conf << { name: '推广中心', icon: 'gear',
          sub_menus: [
              {name: '满减优惠', icon: 'dashboard', features: [:model_order_promotion], permission: [:shop, :order_promotion, :show], path_array: shop_scope(:order_promotions)},
              {name: '免赠促销', icon: 'dashboard', features: [:model_event_promotion], permission: [:shop, :event_promotion, :show], path_array: shop_scope(:event_promotions)},
              {name: '折扣方案', icon: 'dashboard', features: [:model_discount_plan], permission: [:branch, :discount_plan, :show], path_array: branch_scope(:discount_plans)},
              {name: '朋友圈分享记录', icon: 'dashboard', features: [:model_wechat_share_record], permission: [:shop, :wechat_account, :manage], path_array: shop_scope(:wechat_share_records)},
              {name: '签到记录', icon: 'dashboard', features: [:model_sign_record], permission: [:shop, :sign_record, :show], path_array: shop_scope(:sign_records)},
              {name: '评论记录', icon: 'dashboard', features: [:model_comment], permission: [:branch, :comment, :show], path_array: branch_scope(:comments)}
            ]
        }
        menu_conf << { name: '卡券中心', icon: 'gear',
          sub_menus: [
              {name: '团购券', icon: 'dashboard', features: [:model_groupon_version], permission: [:shop, :groupon_version, :show], path_array: shop_scope(:groupon_versions)},
              {name: '优惠券', icon: 'dashboard', features: [:model_coupon_version], permission: [:shop, :coupon_version, :show], path_array: shop_scope(:coupon_versions)},
          ]
        }
        menu_conf << { name: '物料模块', icon: 'gear',
          sub_menus: [
              {name: '二维码  ', icon: 'dashboard', features: [:model_base_qr_code_scene], permission: [:shop, :qrcode, :show], path_array: shop_scope(:base_qr_code_scenes)},
              {name: '排号二维码', icon: 'dashboard', features: [:model_supply], permission: [:shop, :qrcode, :show], path_array: shop_scope(:supplies).unshift(:queue_qr_codes)},
              {name: '门贴二维码', icon: 'dashboard', features: [:model_supply], permission: [:shop, :qrcode, :show], path_array: shop_scope(:supplies).unshift(:door_stickers)},
              {name: '快餐二维码', icon: 'dashboard', features: [:model_supply], permission: [:shop, :qrcode, :show], path_array: shop_scope(:supplies).unshift(:fastfood_stickers)}
            ]
        }
        menu_conf << { name: '会员魔方', icon: 'dashboard', features: [:model_vip_search], permission: [:shop, :user, :show], path_array: shop_scope(:vip_searches)}
        @menus.concat menu_conf
      end

      def kitchen
        menu_conf = []
        menu_conf << { name: '厨控设置', icon: 'dashboard', features: [:model_kitchen_setting], permission: [:shop, :account, :show], path_array: branch_scope(:kitchen_setting)}
        menu_conf << { name: '菜品分配', icon: 'dashboard', features: [:model_cook], permission: [:shop, :account, :show], path_array: branch_scope(:cooks)}
        @menus.concat menu_conf
      end

      def statistic
        menu_conf = []
        menu_conf << { name: '历史查询', icon: 'dashboard', features: [:model_statistics_cache], permission: [:shop, :statistic, :statistics_cache], path_array: shop_scope(:statistics_caches)}
        menu_conf << { name: '订单分析', icon: 'dashboard', features: [:model_orders_statistic], permission: [:shop, :statistic, :orders_statistic], path_array: shop_scope(:orders_statistics).unshift(:order_count_by_day)}
        menu_conf << { name: '菜品分析', icon: 'dashboard', features: [:model_product_statistic], permission: [:shop, :statistic, :product_statistic], path_array: shop_scope(:product_statistics).unshift(:product_summary)}
        menu_conf << { name: '桌台分析', icon: 'dashboard', features: [:model_table_statistic], permission: [:shop, :statistic, :table_statistic], path_array: shop_scope(:table_statistics).unshift(:summary)}
        menu_conf << { name: '用户分析', icon: 'dashboard', features: [:model_user_statistic], permission: [:shop, :statistic, :user_statistic], path_array: shop_scope(:user_statistics).unshift(:new_user)}
        menu_conf << { name: '营业分析', icon: 'dashboard', features: [:model_business_statistic], permission: [:shop, :statistic, :business_statistic], path_array: shop_scope(:business_statistics).unshift(:sales_by_month)}
        menu_conf << { name: '促销分析', icon: 'dashboard', features: [:model_coupon_statistic], permission: [:shop, :statistic, :coupon_statistic], path_array: shop_scope(:coupon_statistics).unshift(:coupon_summary)}
        menu_conf << { name: '工作分析', icon: 'dashboard', features: [:model_worker_statistic], permission: [:shop, :statistic, :coupon_statistic], path_array: shop_scope(:worker_statistics).unshift(:serve)}
        menu_conf << { name: '财务报表', icon: 'dashboard', features: [:model_finance_statistic], permission: [:shop, :statistic, :finance_statistic], path_array: shop_scope(:finance_statistics).unshift(:combi_t1)}
        menu_conf << { name: '其他分析', icon: 'dashboard', features: [:model_short_message], permission: [:shop, :short_message_setting, :show], path_array: shop_scope(:short_messages)}
        @menus.concat menu_conf
      end

      def queue
        menu_conf = []
        menu_conf << {name: '排号二维码', icon: 'gear', features: [:model_supply], permission: [:shop, :qrcode, :show], path_array: shop_scope(:supplies).unshift(:queue_qr_codes)}
        menu_conf << {name: '排号设置', icon: 'gear', features: [:model_arranging_setting], permission: [:branch, :arranging_setting, :show], path_array: branch_scope(:arranging_setting)}
        menu_conf << {name: '队列设置', icon: 'gear', features: [:model_queue_setting], permission: [:branch, :queue_setting, :show], path_array: branch_scope(:queue_settings)}
        menu_conf << {name: '客人队列', icon: 'gear', features: [:model_queue_setting], permission: [:branch, :queue_setting, :show], path_array: branch_scope(:queue_settings).unshift(:board)}
        menu_conf << { name: '微信餐厅', icon: 'gear',
          sub_menus: [
              {name: '门店图标', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types).unshift(:index_branch_nav)},
              {name: '首页模板', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).unshift(:edit)},
              {name: '开机动画', icon: 'dashboard', features: [:model_one_pages], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:one_pages)},
              {name: '导航链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_hot_links)},
              {name: '实用链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_usable_links)},
              {name: '链接工厂', icon: 'dashboard', features: [:weixin_api], permission: [:shop, :wechat_config, :update], path_array: shop_scope(nil).unshift(:copy_link)},
              {name: '餐厅服务', icon: 'dashboard', features: [:model_waiter_service_item], permission: [:branch, :waiter_service_item, :show], path_array: branch_scope(:waiter_service_items)},
              {name: '自定义表单',icon:'dashboard', features: [:model_form_element], permission: [:branch, :form_element, :show], path_array: branch_scope(:form_elements)},
            ]
        }
        @menus.concat menu_conf
      end

      def eat_in_hall
        menu_conf = []
        menu_conf << { name: '堂点设置', icon: 'gear', features: [:model_eat_in_hall_setting], permission: [:branch, :eat_in_hall_setting, :show], path_array: branch_scope(:eat_in_hall_setting)}
        menu_conf << { name: '桌台分类', icon: 'dashboard', features: [:model_table_zone], permission: [:branch, :table_zone, :create], path_array: branch_scope(:table_zones)}
        menu_conf << { name: '桌台管理', icon: 'dashboard', features: [:model_table], permission: [:branch, :table, :create], path_array: branch_scope(:tables)}
        menu_conf << { name: '打印设置', icon: 'dashboard', permission: [:branch, :order, :reprint], features: [:model_print_setting], permission: [:branch, :print_setting, :update], path_array: branch_scope(:print_setting)}
        menu_conf << { name: '配打印机', icon: 'dashboard', permission: [:branch, :order, :reprint], features: [:model_printer], permission: [:branch, :printer, :update], path_array: branch_scope(:printers)}
        menu_conf << { name: '打印档口', icon: 'dashboard', permission: [:branch, :order, :reprint], features: [:model_printer], permission: [:branch, :printer, :update], path_array: branch_scope(:printers).unshift(:products)}
        menu_conf << { name: '微信餐厅', icon: 'gear',
          sub_menus: [
              {name: '门店图标', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types).unshift(:index_branch_nav)},
              {name: '首页模板', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).unshift(:edit)},
              {name: '开机动画', icon: 'dashboard', features: [:model_one_pages], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:one_pages)},
              {name: '导航链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_hot_links)},
              {name: '实用链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_usable_links)},
              {name: '链接工厂', icon: 'dashboard', features: [:weixin_api], permission: [:shop, :wechat_config, :update], path_array: shop_scope(nil).unshift(:copy_link)},
              {name: '餐厅服务', icon: 'dashboard', features: [:model_waiter_service_item], permission: [:branch, :waiter_service_item, :show], path_array: branch_scope(:waiter_service_items)},
              {name: '自定义表单',icon:'dashboard', features: [:model_form_element], permission: [:branch, :form_element, :show], path_array: branch_scope(:form_elements)},
            ]
        }
        @menus.concat menu_conf
      end
      alias_method :eat_in_hall_on_wechat, :eat_in_hall


      def delivery
        menu_conf = []
        menu_conf << { name: '外送设置', icon: 'gear', features: [:model_delivery_setting], permission: [:branch, :delivery_setting, :show], path_array: branch_scope(:delivery_setting)}
        menu_conf << { name: '微信餐厅', icon: 'gear',
          sub_menus: [
              {name: '门店图标', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types).unshift(:index_branch_nav)},
              {name: '首页模板', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).unshift(:edit)},
              {name: '开机动画', icon: 'dashboard', features: [:model_one_pages], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:one_pages)},
              {name: '导航链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_hot_links)},
              {name: '实用链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_usable_links)},
              {name: '链接工厂', icon: 'dashboard', features: [:weixin_api], permission: [:shop, :wechat_config, :update], path_array: shop_scope(nil).unshift(:copy_link)},
              {name: '餐厅服务', icon: 'dashboard', features: [:model_waiter_service_item], permission: [:branch, :waiter_service_item, :show], path_array: branch_scope(:waiter_service_items)},
              {name: '自定义表单',icon:'dashboard', features: [:model_form_element], permission: [:branch, :form_element, :show], path_array: branch_scope(:form_elements)},
            ]
        }
        @menus.concat menu_conf
      end
      alias_method :delivery_on_wechat,    :delivery


      def fastfood
        menu_conf = []
        menu_conf << {name: '快餐二维码', icon: 'gear', features: [:model_supply], permission: [:shop, :qrcode, :show], path_array: shop_scope(:supplies).unshift(:fastfood_stickers)}
        menu_conf << { name: '微信餐厅', icon: 'gear',
          sub_menus: [
              {name: '门店图标', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types).unshift(:index_branch_nav)},
              {name: '首页模板', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).unshift(:edit)},
              {name: '开机动画', icon: 'dashboard', features: [:model_one_pages], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:one_pages)},
              {name: '导航链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_hot_links)},
              {name: '实用链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_usable_links)},
              {name: '链接工厂', icon: 'dashboard', features: [:weixin_api], permission: [:shop, :wechat_config, :update], path_array: shop_scope(nil).unshift(:copy_link)},
              {name: '餐厅服务', icon: 'dashboard', features: [:model_waiter_service_item], permission: [:branch, :waiter_service_item, :show], path_array: branch_scope(:waiter_service_items)},
              {name: '自定义表单',icon:'dashboard', features: [:model_form_element], permission: [:branch, :form_element, :show], path_array: branch_scope(:form_elements)},
            ]
        }
        @menus.concat menu_conf
      end
      alias_method :fastfood_on_wechat,    :fastfood


      def reservation
        menu_conf = []
        menu_conf << { name: '预订设置', icon: 'dashboard', features: [:model_reservation_setting], permission: [:branch, :reservation_setting, :update], path_array: branch_scope(:reservation_setting)}
        menu_conf << { name: '预定时段', icon: 'dashboard', features: [:model_reservation_time_point], permission: [:branch, :reservation_setting, :update], path_array: branch_scope(:reservation_time_points)}
        @menus.concat menu_conf
      end

      def reservation_on_wechat
        reservation
        menu_conf = []
        menu_conf << { name: '桌台分类', icon: 'dashboard', features: [:model_table_zone], permission: [:branch, :table_zone, :create], path_array: branch_scope(:table_zones)}
        menu_conf << { name: '微信餐厅', icon: 'gear',
          sub_menus: [
              {name: '门店图标', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types).unshift(:index_branch_nav)},
              {name: '首页模板', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).unshift(:edit)},
              {name: '开机动画', icon: 'dashboard', features: [:model_one_pages], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:one_pages)},
              {name: '导航链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_hot_links)},
              {name: '实用链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_usable_links)},
              {name: '链接工厂', icon: 'dashboard', features: [:weixin_api], permission: [:shop, :wechat_config, :update], path_array: shop_scope(nil).unshift(:copy_link)},
              {name: '餐厅服务', icon: 'dashboard', features: [:model_waiter_service_item], permission: [:branch, :waiter_service_item, :show], path_array: branch_scope(:waiter_service_items)},
              {name: '自定义表单',icon:'dashboard', features: [:model_form_element], permission: [:branch, :form_element, :show], path_array: branch_scope(:form_elements)},
            ]
        }
        @menus.concat menu_conf
      end

      def chain
        menu_conf = []
        menu_conf << { name: '门店分类', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types)}
        menu_conf << { name: '门店分组', icon: 'dashboard', features: [:model_branch_group], permission: [:shop, :branch_group, :update], path_array: shop_scope(:branch_groups)}
        menu_conf << { name: '产品复制', icon: 'dashboard', features: [:model_product], permission: [:branch, :product, :create], path_array: branch_scope(:products)}
        @menus.concat menu_conf
      end

      def business_circle
        menu_conf = []
        menu_conf << { name: '门店分类', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types)}
        menu_conf << { name: '门店分组', icon: 'dashboard', features: [:model_branch_group], permission: [:shop, :branch_group, :update], path_array: shop_scope(:branch_groups)}
        menu_conf << { name: '门店区域', icon: 'dashboard', features: [:model_zone], permission: [:shop, :zone, :update], path_array: shop_scope(:zones)}
        @menus.concat menu_conf
      end


      def sdu
        menu_conf = []
        menu_conf << { name: '数据上传', icon: 'gear', features: [:model_sale_data_uploader_setting], permission: [], path_array: branch_scope(:sale_data_uploader_setting)}
        @menus.concat menu_conf
      end

      def cs
        menu_conf = []
        menu_conf << { name: '离线模式', icon: 'gear', features: [:model_cs_branch_binding], permission: [:branch, :cs_branch_binding, :show], path_array: branch_scope(:cs_branch_binding)}
        @menus.concat menu_conf
      end

      def bill_template
        base
      end

      def groupon
        menu_conf = []
        menu_conf << {name: '团购券', icon: 'dashboard', features: [:model_groupon_version], permission: [:shop, :groupon_version, :show], path_array: shop_scope(:groupon_versions)}
        menu_conf << { name: '微信餐厅', icon: 'gear',
          sub_menus: [
              {name: '门店图标', icon: 'dashboard', features: [:model_branch_type], permission: [:shop, :branch_type, :update], path_array: shop_scope(:branch_types).unshift(:index_branch_nav)},
              {name: '首页模板', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).unshift(:edit)},
              {name: '开机动画', icon: 'dashboard', features: [:model_one_pages], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:one_pages)},
              {name: '导航链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_hot_links)},
              {name: '实用链接', icon: 'dashboard', features: [:model_custom_weixin_info], permission: [:shop, :wechat_config, :update], path_array: shop_scope(:custom_weixin_info).push(:home_usable_links)},
              {name: '链接工厂', icon: 'dashboard', features: [:weixin_api], permission: [:shop, :wechat_config, :update], path_array: shop_scope(nil).unshift(:copy_link)},
              {name: '餐厅服务', icon: 'dashboard', features: [:model_waiter_service_item], permission: [:branch, :waiter_service_item, :show], path_array: branch_scope(:waiter_service_items)},
              {name: '自定义表单',icon:'dashboard', features: [:model_form_element], permission: [:branch, :form_element, :show], path_array: branch_scope(:form_elements)},
            ]
        }
        @menus.concat menu_conf
      end

      def initialize(view, account:, current_shop:, current_branch:)
        @view = view
        @account = account
        @current_shop = current_shop
        @current_branch = current_branch
        @menus = []
        menu_group = view.session[:menu_group]
        admin_bar if account && account.is_admin?
        if current_shop.present?
          if menu_group.present? && MENU_GROUPS.include?(menu_group.to_sym)
            dashboard
            self.send menu_group.to_sym
          else
            base
          end
        end
      end

      def admin_scope(entity)
        ScopedPathArray.new(:admin, [:backend, entity])
      end

      def shop_scope(entity)
        ScopedPathArray.new(:shop, [:backend, current_shop, entity])
      end

      def branch_scope(entity)
        ScopedPathArray.new(:branch, [:backend, current_shop, current_branch, entity])
      end


      def set_state
        @menus.each do |menu|
          if menu[:sub_menus].blank?
            menu = set_state_of(menu)
          else
            menu[:sub_menus].each do |sub_menu|
              sub_menu = set_state_of(sub_menu)
            end
            menu[:active]    = menu[:sub_menus].any?{|sub_menu| sub_menu[:active]}
            menu[:expired]   = menu[:sub_menus].all?{|sub_menu| sub_menu[:expired]}
            menu[:permitted] = menu[:sub_menus].any?{|sub_menu| sub_menu[:permitted]}
          end
        end
      end

      def set_state_of(menu)
        menu[:expired] = true
        menu[:permitted] = false
        # determine active item

        if [@view.controller_name.pluralize, @view.controller_name.singularize].include?(menu[:path_array].last.to_s)
          menu[:active] = true
        end

        # determine if module is expired
        if menu[:features].present? || menu[:modules].present?
          menu[:expired] = true
          # determine if expires by modules
          menu[:modules].try(:each) do |mod|
            if current_shop.has_module?(mod)
              menu[:expired] = false
            end
          end
          # determine if expires by features
          menu[:features].try(:each) do |feature|
            if current_shop.has_feature? feature
              menu[:expired] = false
            end
          end
        else
          # default all shop has module/feature
          menu[:expired] = false
        end

        # check permission
        if menu[:permission].present?
          permission = menu[:permission]
          permitted = account.can?(permission[0], permission[1], permission[2])
          menu[:permitted] = permitted
        else
          menu[:permitted] = true
        end
        menu
      end


      def render_result
        # menu: {:name, :icon, :path_array, :permitted, :expired, :active, sub_menus: []}
        # render to html
        set_state
        menu_option_keys = [:permitted, :expired, :active, :number]
        html = ''
        html << @menus.map do |menu|
          if menu[:sub_menus].present?
            menu_toggle(menu[:name], menu[:icon], menu.slice(*menu_option_keys)) do
              menu[:sub_menus].map do |sub_menu|
                menu_tag(sub_menu[:name], sub_menu[:path_array], sub_menu[:icon], sub_menu.slice(*([:target] + menu_option_keys)))
              end.join.html_safe
            end.html_safe
          else
            menu_tag(menu[:name], menu[:path_array], menu[:icon], menu.slice(*menu_option_keys))
          end
        end.join.html_safe
        html.html_safe
      end

      def sidebar_nav_struct
        html <<-HTML
          .ul.nav.nav-list
            %li.active
              %a.dropdown-toggle{:href='#'}
                %i.fa.fa-bank.icon-
                %span.menu-text MENUNAME
                %b.arrow.fa.fa-angle-down
              %ul.submenu
        HTML
      end

      def menu_tag(name, path_array, icon, target: :_self, permitted: true, expired: false, active: false, number: 0)
        if permitted && !expired
          if path_array.is_a? ScopedPathArray
            if path_array.branch_scope?
              path = view.branch_link(current_branch, path_array.members)
            else
              path = view.polymorphic_path(path_array.members)
            end
          elsif path_array.is_a? String
            path = path_array
          else
            raise 'no support'
          end
          content_tag(:li, class: (active ? 'active' : '')) do
            content_tag(:a, href: path, target: target) do
              html = content_tag(:i, '', class: "fa fa-#{icon} icon-") + name
              html << notice_tag(number)
            end
          end
        end
      end

      def menu_toggle(name, icon, permitted: true, expired: false, active: false, number: 0)
        if permitted && !expired
          content_tag(:li, class: (active ? 'active' : '')) do
            toggle = content_tag(:a, class: "dropdown-toggle", href: "#") do
              str = content_tag(:i, '', class: "fa fa-#{icon} icon-")
              str << content_tag(:span, name, class: "nav-label")
              str << notice_tag(number)
              str << content_tag(:span, '', class: "fa arrow")
              str.html_safe
            end
            submenu = content_tag(:ul, class: 'nav nav-second-level collapse') do
              yield.html_safe
            end
            toggle + submenu
          end
        else
          ''
        end
      end


      def notice_tag(number, color: "success")
        if number.present? && number > 0
          return content_tag(:span, number.to_s, class: "badge badge-#{color}")
        end
        return ''
      end

      class ScopedPathArray < SimpleDelegator
        attr_accessor :members
        def initialize(scope, members)
          @scope, @members = scope, members
          super(@members)
        end

        def push(item)
          @members.push(item)
          self
        end

        def unshift(item)
          @members.unshift(item)
          self
        end

        def branch_scope?
          @scope == :branch
        end
      end


    end
  end
end

