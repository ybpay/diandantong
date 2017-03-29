#encoding: utf-8
module Ddt

  #
  # 开头为 create_ 的实例方法会在创建 Shop 时在 after_create 钩子中自动调用，
  #
  class ShopInitializer

    attr_reader :shop

    def initialize(shop)
      @shop = shop
      @image_dir_prefix = ShopDefaultConfig.image_dir_prefix
    end

    def process
      self.class.instance_methods.grep(/^create_/).each do |method|
        # 带 '!' 结尾的方法要创建的内容是必须创建的
        send(method) if method[-1] == '!'
      end
      branch = @shop.branches.first
      create_branch_data(branch)
    end

    def create_shop
      extra_params = {}
      extra_params['image'] = open_image(ShopDefaultConfig.shop.image)
      extra_params['rect_image'] = open_image(ShopDefaultConfig.shop.rect_image)
      extra_params['vip_logo'] = open_image(ShopDefaultConfig.shop.vip_logo)
      shop.update!(ShopDefaultConfig.shop.merge(extra_params))
    end

    def create_system_builtin_roles!
      Role.types.reject{|type| [:admin, :custom].include? type}.each do |type|
        shop.roles.create!(type: "Ddt::Role::#{type.to_s.camelize}", name: type, builtin: true)
      end
    end

    def create_branch_type!
      shop.branch_types.create!(name: '默认类型')
    end

    def create_table_color!
      shop.create_table_color!
    end

    def create_coupon_setting!
      shop.create_coupon_setting!
    end

    def create_vip_info_setting!
      shop.create_vip_info_setting!
    end

    def create_payment_methods!
      shop.create_alipay_method
      shop.create_wechatpay_method_legacy!
      shop.create_wechatpay_method_v336!
    end

    def create_wallets!
      shop.create_card_wallet!
      shop.create_credits_wallet!
      shop.create_collection_wallet!
    end

    def create_pay_method_settings!
      shop.create_delivery_pay_method_setting!
      shop.create_eat_in_hall_pay_method_setting!
      shop.create_fastfood_pay_method_setting!
      shop.create_groupon_pay_method_setting!
      shop.create_reservation_pay_method_setting!
      shop.create_recharge_pay_method_setting!
      shop.create_payment_pay_method_setting!
    end

    def create_custom_info!
      custom_info = shop.custom_weixin_info || shop.create_custom_weixin_info!(layout_type: 'classic')
      home_hot_links = []
      home_hot_links << custom_info.home_hot_links.build{{label: '找餐厅', icon: 'fa-weixin', icon_background_color: '#fb5855', link: '#/branches', is_multiple: true}}
      home_hot_links << custom_info.home_hot_links.build({label: '找优惠', icon: 'fa-tags', icon_background_color: '#ffa321', link: '#/promotions', is_multiple: true})
      home_hot_links << custom_info.home_hot_links.build({label: '找外卖', icon: 'fa-truck', icon_background_color: '#00c8e0', link: '#/delivery_branches', is_multiple: true})
      home_hot_links << custom_info.home_hot_links.build({label: '签到', icon: 'fa-tag', icon_background_color: '#ffa321', link: '#/sign_records', is_multiple: false})
      home_hot_links << custom_info.home_hot_links.build({label: '券包', icon: 'fa-money', icon_background_color: '#00c8e0', link: '#/user/coupon_nav', is_multiple: false})
      Ddt::HomeHotLink.import(home_hot_links)
    end

    def create_default_abstract_branch!
      Ddt::Branch.create!(shop: shop, name: shop.name, phone: shop.telephone, branch_category: 'others', is_abstract: true, latitude: 0, longitude: 0)
    end

    def create_default_branch!
      shop.branches.create!(
          ShopDefaultConfig.branch.merge(
              'image' => nil,
              'rect_image' => nil,
              'branch_type' => shop.branch_types.first,
              'enable_tts_local' => true
          )
      )
    end

    def create_branch_data(branch)
      tablezone1 = branch.table_zones.create(name:'大厅',reservation_price_percent: 100)
      tablezone1.tables.create(name: '包厢第一张桌子', capacity: 22)
      categoryA = branch.categories.create(name:'蔬菜')
      branch.products.create(name: '大白菜',unit_name: '份',description: '大白菜',category_ids_string:categoryA.id,price: 25 ,vip_price: 22 ,availabled_at: Time.now)
      branch.combos.create(name:'两荤一素',unit_name: '份',description: '两荤一素',availabled_at: Time.now)
    end










    def create_default_vip_level!
      shop.vip_levels.create!({
          name: '普通用户',
          discount: 1,
          is_default: true,
          level: 0,
          skip_validate_level: true
        }) if shop.vip_levels.where(is_default: true).count == 0

    end

    def create_default_vip_levels
      vip_levels  = []
      ShopDefaultConfig.vip_levels.each do |k, cfg|
        vip_levels << shop.vip_levels.build(cfg)
      end
      Ddt::VipLevel.import(vip_levels)
    end

    def create_email_setting!
      shop.create_email_setting
    end

    def create_short_message_setting!
      shop.create_short_message_setting!
    end

    def create_call_setting!
      shop.create_call_setting!
    end

    def create_credits_setting!
      shop.create_credits_setting!
    end

    def create_card_key!
      shop.update_column(:card_key, "%0.12x" % rand(16**12))
    end

    def create_competition_resource!
      shop.competition_resources.create!(name: :order_number)
    end

    def create_default_pay_method!
      if shop.pay_methods.count == 0
        pay_methods = []
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :pay_on_face    , name: "现金" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :pay_on_receive , name: "货到付款" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :pay_on_arrive  , name: "到店付款" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :alipay         , name: "支付宝" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :wechatpay      , name: "微信支付" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :baidupay       , name: "百付宝" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :vip_card_pay   , name: "会员卡" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :bank_card_pay  , name: "银行卡" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :alipay_offline , name: "线下支付宝" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :wechatpay_offline , name: "线下微信支付" })
        pay_methods << shop.pay_methods.builtin.build({ name_sym: :tick_for_account , name: "挂账" })
        Ddt::PayMethod.import(pay_methods)
      end
    end

    private
    def open_image(uri_path)
      open(Rails.root.join(@image_dir_prefix + uri_path))
    end


  end
end
