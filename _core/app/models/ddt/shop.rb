#encoding: utf-8
require 'carrierwave/orm/activerecord'
module Ddt
  class Shop < Ddt::Base
    include Ddt::TrackFrom
    auto_strip_attributes :custom_domain
    is_impressionable
    ### relationships
    default_scope ->{ order(created_at: :desc) }
    acts_as_paranoid
    replicated_model


    has_one :credits_wallet, as: :owner, class_name: 'Ddt::ShopCreditsWallet'
    has_one :card_wallet, as: :owner, class_name: 'Ddt::ShopCardWallet'
    has_one :collection_wallet, as: :owner, class_name: 'Ddt::CollectionWallet'
    has_one :custom_weixin_info, class_name: 'Ddt::CustomWeixinInfo'
    has_one :email_setting, class_name: 'Ddt::EmailSetting'
    has_one :short_message_setting, class_name: 'Ddt::ShortMessageSetting'
    has_one :call_setting, class_name: 'Ddt::CallSetting'
    has_one :credits_setting, class_name: 'Ddt::CreditsSetting'
    has_many :competition_resources, class_name: 'Ddt::CompetitionResource', as: :owner
    has_many :all_tags, -> {order(count: :desc)}, class_name: 'Ddt::Tag'

    has_many :wechat_accounts , class_name: 'Ddt::WechatAccount'
    has_many :weixin_pages, class_name: 'Ddt::WeixinPage'
    has_many :base_users      , class_name: 'Ddt::BaseUser'
    has_many :users                    , dependent: :destroy , class_name: 'Ddt::User'
    has_many :web_users                , dependent: :destroy , class_name: 'Ddt::WebUser'
    has_many :phone_users              , dependent: :destroy , class_name: 'Ddt::PhoneUser'
    has_many :wechat_users             , dependent: :destroy , class_name: 'Ddt::WechatUser'
    has_many :vip_infos                , dependent: :destroy , class_name: 'Ddt::VipInfo'
    has_many :applying_vip_infos       , ->{ applying}, dependent: :destroy , class_name: 'Ddt::VipInfo', counter_cache: true
    has_many :vip_levels               , dependent: :destroy , class_name: 'Ddt::VipLevel'
    has_many :branches                 , ->{ real.order("position ASC")}, dependent: :destroy , class_name: 'Ddt::Branch'
    has_one  :abstract_branch          , ->{ abstract }, dependent: :destroy , class_name: 'Ddt::Branch'
    has_many :branches_include_abstract, class_name: 'Ddt::Branch'
    has_many :branch_types             , dependent: :destroy , class_name: 'Ddt::BranchType'
    has_many :branch_groups            , dependent: :destroy , class_name: 'Ddt::BranchGroup'
    has_many :roles                    , dependent: :destroy , class_name: 'Ddt::Role'
    has_many :accounts                 , dependent: :destroy , class_name: 'Ddt::Account'
    has_many :abstract_coupon_versions , dependent: :destroy , class_name: 'Ddt::AbstractCouponVersion'
    has_many :base_coupons             , dependent: :destroy , class_name: 'Ddt::BaseCoupon'
    has_many :groupon_versions         , dependent: :destroy , class_name: 'Ddt::GrouponVersion'
    has_many :groupons                 , dependent: :destroy , class_name: 'Ddt::Groupon'
    has_many :voucher_versions         , dependent: :destroy , class_name: 'Ddt::VoucherVersion'
    has_many :vouchers                 , dependent: :destroy , class_name: 'Ddt::Voucher'
    has_many :coupon_versions          , dependent: :destroy , class_name: 'Ddt::CouponVersion'
    has_many :coupons                  , dependent: :destroy , class_name: 'Ddt::Coupon'
    has_many :queue_settings           , dependent: :destroy , class_name: 'Ddt::QueueSetting'
    has_many :guest_queues             , dependent: :destroy , class_name: 'Ddt::GuestQueue'
    has_many :zones                    , dependent: :destroy , class_name: 'Ddt::Zone'
    has_many :short_messages           , dependent: :destroy , class_name: 'Ddt::ShortMessage'
    has_many :order_calls              , dependent: :destroy , class_name: 'Ddt::OrderCall'

    has_many :printer_codes            , dependent: :destroy , class_name: 'Ddt::PrinterCode'

    has_many_orders :orders
    has_many_orders :delivery_orders,    ->{ delivery }
    has_many_orders :reservation_orders, ->{ reservation }
    has_many_orders :eat_in_hall_orders, ->{ eat_in_hall }
    has_many_orders :fastfood_orders,    ->{ fastfood }
    has_many_orders :groupon_orders,     ->{ groupon }
    has_many_orders :recharge_orders,    ->{ recharge }
    has_many_orders :payment_orders,     ->{ payment }

    has_many :payments                 , dependent: :destroy , class_name: 'Ddt::Payment'
    has_many :payment_logs             , dependent: :destroy, class_name: 'Ddt::PaymentLog'
    has_many :payment_methods          , dependent: :destroy , class_name: 'Ddt::PaymentMethod'
    has_one :alipay_method             , dependent: :destroy , class_name: 'Ddt::AlipayMethod'
    has_one :wechatpay_method_v336     , dependent: :destroy , class_name: 'Ddt::WechatpayMethodV336'
    has_one :wechatpay_method_legacy   , dependent: :destroy, :class_name => 'Ddt::WechatpayMethodLegacy'
    has_many :message_receptions       , dependent: :destroy , class_name: 'Ddt::MessageReception'
    has_many :promotions               , ->{ in_shop }, dependent: :destroy, class_name: 'Ddt::Promotion'
    has_many :promotions_including_branch, dependent: :destroy, class_name: 'Ddt::Promotion'
    has_many :event_promotions         , ->{ in_shop }, dependent: :destroy, class_name: 'Ddt::EventPromotion'
    has_many :event_promotions_including_branch, dependent: :destroy, class_name: 'Ddt::EventPromotion'
    has_many :order_promotions         , ->{ in_shop }, dependent: :destroy, class_name: 'Ddt::OrderPromotion'
    has_many :order_promotions_including_branch, dependent: :destroy, class_name: 'Ddt::OrderPromotion'
    has_many :promotion_rules          , ->{ in_shop}, dependent: :destroy, :class_name => 'Ddt::PromotionRule'
    has_many :promotion_rules_including_branch, dependent: :destroy, :class_name => 'Ddt::PromotionRule'
    has_many :promotion_actions        , ->{ in_shop}, dependent: :destroy, :class_name => 'Ddt::PromotionAction'
    has_many :promotion_actions_including_branch, dependent: :destroy, :class_name => 'Ddt::PromotionAction'
    has_many :branch_sliders           ,-> { order("position ASC") }, dependent: :destroy , class_name: 'Ddt::BranchSlider'
    has_many :categories               , dependent: :destroy , class_name: 'Ddt::Category'
    has_many :materials                , ->{includes(:shop)}, dependent: :destroy, class_name: 'Ddt::Material'
    has_many :wechat_share_records     , -> { where(verified: true)}, dependent: :destroy, class_name: 'Ddt::WechatShareRecord'
    has_many :tags                     , -> {order(count: :desc)}, class_name: 'Ddt::Tag'
    has_many :branch_tags              , class_name: 'Ddt::BranchTag'
    has_many :one_pages , ->{order("position ASC")}, class_name: 'Ddt::OnePage'
    has_one :table_color, class_name: 'Ddt::TableColor'

    has_many :articles                 ,class_name: 'Ddt::Article'
    has_many :events                   , dependent: :destroy, class_name: 'Ddt::Event'
    has_many :base_qr_code_scenes      , dependent: :destroy , class_name: 'Ddt::BaseQrCodeScene'
    has_many :qr_code_scenes           , dependent: :destroy , class_name: 'Ddt::QrCodeScene'
    has_many :wechat_qr_code_scenes    , dependent: :destroy , class_name: 'Ddt::WechatQrCodeScene'
    has_many :pay_qr_code_scenes       , dependent: :destroy , class_name: 'Ddt::PayQrCodeScene'
    has_many :verify_vip_info_qr_code_scenes, dependent: :destroy , class_name: 'Ddt::VerifyVipInfoQrCodeScene'
    has_many :shop_recharge_records    , dependent: :destroy , class_name: 'Ddt::ShopRechargeRecord'
    has_many :sign_records             , dependent: :destroy , class_name: 'Ddt::SignRecord'
    has_many :wallet_logs            , class_name: 'Ddt::WalletLog'
    has_many :branch_card_wallets    , class_name: 'Ddt::BranchCardWallet'
    has_many :branch_credits_wallets , class_name: 'Ddt::BranchCreditsWallet'
    has_many :user_card_wallets      , class_name: 'Ddt::UserCardWallet'
    has_many :user_credits_wallets   , class_name: 'Ddt::UserCreditsWallet'
    has_many :merchant_applies       , dependent: :destroy
    has_many :exchange_codes         , dependent: :destroy , class_name: 'Ddt::ExchangeCode'
    has_many :sharable_coupons       , dependent: :destroy , class_name: 'Ddt::SharableCoupon'
    has_many :service_product_orders , dependent: :destroy , class_name: 'Ddt::ServiceProductOrder'
    has_one :delivery_pay_method_setting, ->{in_shop}, class_name: 'Ddt::PayMethodSetting::Delivery', dependent: :destroy
    has_one :eat_in_hall_pay_method_setting, ->{in_shop}, class_name: 'Ddt::PayMethodSetting::EatInHall', dependent: :destroy
    has_one :fastfood_pay_method_setting, ->{in_shop}, class_name: 'Ddt::PayMethodSetting::Fastfood', dependent: :destroy
    has_one :groupon_pay_method_setting, ->{in_shop}, class_name: 'Ddt::PayMethodSetting::Groupon', dependent: :destroy
    has_one :reservation_pay_method_setting, ->{in_shop}, class_name: 'Ddt::PayMethodSetting::Reservation', dependent: :destroy
    has_one :recharge_pay_method_setting, ->{in_shop}, class_name: 'Ddt::PayMethodSetting::Recharge', dependent: :destroy
    has_one :payment_pay_method_setting, ->{in_shop}, class_name: 'Ddt::PayMethodSetting::Payment', dependent: :destroy
    has_one :vip_info_setting
    has_many :uploaded_files
    has_many :recharge_refunds
    has_many :feature_modules_configs, class_name: 'Ddt::FeatureModulesConfig', dependent: :destroy
    attr_accessor :feature_module_names_str
    has_one :coupon_setting

    [:delivery, :eat_in_hall, :fastfood, :groupon, :reservation, :recharge, :payment].each do |it|
      alias_method "direct_#{it}_pay_method_setting".to_sym, "#{it}_pay_method_setting".to_sym
      define_method "#{it}_pay_method_setting" do
        if TCC.enable?
          TCC.fetch("shop.#{self.id}.#{it}_pay_method_setting") {super()}
        else
          self.send "direct_#{it}_pay_method_setting".to_sym
        end
      end
    end

    accepts_nested_attributes_for :delivery_pay_method_setting, update_only: true
    accepts_nested_attributes_for :eat_in_hall_pay_method_setting, update_only: true
    accepts_nested_attributes_for :fastfood_pay_method_setting, update_only: true
    accepts_nested_attributes_for :groupon_pay_method_setting, update_only: true
    accepts_nested_attributes_for :reservation_pay_method_setting, update_only: true
    accepts_nested_attributes_for :recharge_pay_method_setting, update_only: true
    accepts_nested_attributes_for :payment_pay_method_setting, update_only: true
    has_many :variants, class_name: 'Ddt::Variant'
    has_many :recharge_products, dependent: :destroy, class_name: 'Ddt::RechargeProduct'
    has_many :temp_recharge_products
    has_many :printers, dependent: :destroy, class_name: 'Ddt::Printer'
    has_many :shifts, class_name: 'Ddt::Shift'
    belongs_to :sale_employee, class_name: 'Ddt::SaleEmployee'
    belongs_to :pre_sale_staff, class_name: 'Ddt::PreSaleStaff'
    has_many :variant_images, class_name: 'Ddt::VariantImage'
    belongs_to :agent_zone, class_name: 'Ddt::AgentZone'
    has_many :pay_methods, class_name: 'Ddt::PayMethod'
    has_many :reservation_infos, class_name: 'Ddt::ReservationInfo'
    has_many :gift_reasons, class_name: 'Ddt::GiftReason'
    has_many :subtract_reasons, class_name: 'Ddt::SubtractReason'
    has_many :search_filters, class_name: 'Ddt::SearchFilter'
    has_many :time_intervals, class_name: 'Ddt::TimeInterval'
    has_many :shipments, class_name: 'Ddt::Shipment'
    has_many :statistics_caches, class_name: 'Ddt::StatisticsCache', dependent: :destroy

    mount_uploader :image, ShopImageUploader
    mount_uploader :rect_image, ShopRectImageUploader
    mount_uploader :vip_logo, ShopVipLogoUploader

    mount_uploader :reservation_img, ShopButtonImageUploader
    mount_uploader :order_in_seat_img, ShopButtonImageUploader
    mount_uploader :delivery_img, ShopButtonImageUploader
    mount_uploader :queue_img, ShopButtonImageUploader
    mount_uploader :pay_online_img, ShopButtonImageUploader
    mount_uploader :last_import_vip_info_error, ShopLastImportVipInfoErrorUploader


    ### validations
    validates :reservation_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :reservation_img?
    validates :order_in_seat_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :order_in_seat_img?
    validates :delivery_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :delivery_img?
    validates :queue_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :queue_img?
    validates :pay_online_img, file_size: {maximum: 0.05.megabytes.to_i} , if: :pay_online_img?
    validates :image      , file_size: { maximum: 0.5.megabytes.to_i } , if: :image?
    validates :rect_image , file_size: { maximum: 0.5.megabytes.to_i } , if: :rect_image?
    validates :vip_logo   , file_size: { maximum: 0.5.megabytes.to_i } , if: :vip_logo?
    validates :telephone, presence: true, uniqueness: true
    validates :service_email, email: true, allow_blank: true
    validates :sina_weibo, uri: true, allow_blank: true
    #validates :use_custom_brand, acceptance: true, if: :agent_no?
    validates :slug, shop_slug: true, presence: true, uniqueness: true
    validates :foreign_tax_rate, :numericality => {:greater_than_or_equal_to => 0}
    delegate :enable_vip_info_phone_validation, :enable_vip_info_phone_validation?,  to: :short_message_setting
    validates :custom_domain, :domain_host => true, :allow_blank=>true
    # validates :address, presence: true, on: :create

    # constants
    SHOP_TYPE_MINI     = 'mini'
    SHOP_TYPE_STANDARD = 'standard'
    SHOP_TYPE_CHAIN    = 'chain'
    SHOP_TYPE_MULTIPLE = 'multiple'
    SHOP_TYPE_BASE     = 'base'

    DEFAULT_SHOP_TYPE = SHOP_TYPE_BASE

    SHOP_TYPES = [SHOP_TYPE_MINI, SHOP_TYPE_STANDARD, SHOP_TYPE_CHAIN, SHOP_TYPE_MULTIPLE,SHOP_TYPE_BASE]

    acts_as_type :shop_type, Ddt::FeatureModuleGroup.all, Ddt::FeatureModuleGroup.all_values.map{|t| t[:label]}
    acts_as_type :track_from, [AGENT,BACKEND, APP, WECHAT, MOBILE, UNKNOW], [AGENT_LABEL,BACKEND_LABEL, APP_LABEL, WECHAT_LABEL, MOBILE_LABEL, UNKNOW_LABEL]


    #scopes
    scope :of_oem, -> {where(:use_custom_brand => true)}
    scope :can_send_birthday_sms, -> {
      joins("LEFT JOIN ddt_short_message_settings as a ON ddt_shops.id = a.shop_id").
      where("a.use_sms=true AND a.use_birthday_sms=true AND a.birthday_message IS NOT NULL")
    }

    # callbacks
    before_validation :generate_slug
    before_save :assign_city_code

    after_create :set_agent_no
    after_create {ShopInitializer.new(self).process}
    after_save :record_updated_sale_employee_at
    after_save :record_updated_pre_sale_staff_at
    after_create :create_feature_modules_configs

    ### plugins
    extend FriendlyId
    friendly_id :slug, use: [:slugged, :finders]

    ### methods

    def can_choose_sale_employee?
      agent.blank? && self.recharge_before? && self.sale_employee.blank?
    end

    def primary_boss_account
        self.accounts.find_by(:built_in => 1)
    end

    def recharge_before?
      shop_recharge_records.valid.count > 0
    end

    def support_brand_name
      if self.agent.present?
        self.agent.support_brand_name
      elsif self.use_custom_brand?
        self.custom_brand_name.presence||""
      else
        Ddt::SiteConfig.brand_name
      end
    end

    def not_oem?
      !is_oem?
    end

    def can_recharge_free?
        #是否允许代理商对该帐号免费延期
        is_base? && self.max_recharge_free_time > 0
    end

    def max_recharge_free_time
        #允许代理商最大可延期时间
        (self.created_at + 31.days - self.expiration_time).to_i
    end

    def is_oem?
      is_oem_agent? || has_oem_privilege?
    end

    def is_oem_agent?
      agent.present? && agent.is_oem?
    end

    def has_oem_privilege?
      self.use_custom_brand?
    end


    def agent_brand
      is_oem_agent? ? agent.brand : nil
    end

    def qrcode
      "http://open.weixin.qq.com/qr/code/?username=#{primary_wechat_account.gonghao_open_id}" if primary_wechat_account.present?
    end

    def show_brand_ddt?
      if self.agent.present?
        self.agent.support_brand_name == Ddt::SiteConfig.brand_name
      elsif self.use_custom_brand?
        false
      else
        true
      end
    end

    def self.current= (shop)
      Thread.current[:current_shop] = shop
    end

    def self.current
      Thread.current[:current_shop]
    end

    def support_brand_link
      if self.agent.present?
        self.agent.support_brand_link
      elsif self.use_custom_brand?
        self.custom_brand_link||""
      else
        Ddt::SiteConfig.site
      end
    end

    def support_wechat_introduce_url
      if self.agent.present?
        self.agent.wechat_introduce_url
      elsif self.use_custom_brand?
        self.custom_brand_link||""
      else
        Ddt::SiteConfig.wechat_introduce_url
      end
    end

    def support_telephone
      if self.agent.present?
        self.agent.phone
      elsif self.use_custom_brand?
        self.telephone
      else
        Ddt::SiteConfig.telephone
      end
    end

    def prepaid_phone
      if self.agent.present?
        self.agent.phone
      else
        '18616250389'
      end
    end

    def custom_host
      if self.custom_domain_url.present? &&  self.is_domain_url_validated
        self.custom_domain_url
      end
    end

    def default_vip_level
        self.vip_levels.default_level
    end

    def expired?
      self.expiration_time < Time.now
    end

    def is_open_name
      self.is_open? ? I18n.t("shop.is_open.opening") : I18n.t("shop.is_open.closed")
    end

    def agent
        if self.agent_no.present?
            @agent ||= (Ddt::Agent.with_deleted.find_by(:agent_no => self.agent_no) rescue nil)
        else
            nil
        end
    end

    def active_branches
      branches.open_on_today
    end

    def active_branches_in_distance(user)
      self.active_branches.map{|branch| [branch, branch.distance_of(user)]}.sort{|a, b|
        if a[1].present? && b[1].present?
          if a[1] <= 500 && b[1] <= 500
            a[0].position <=> b[0].position
          else
            a[1] <=> b[1]
          end
        elsif a[1].blank? && b[1].blank?
          a[0].position <=> b[0].position
        elsif a[1].blank?
          1
        elsif b[1].blank?
          -1
        end
      }.map{|a| a[0]}
    end

    def is_multi_branches?
      max_branches_limit > 1
    end

    def primary_wechat_account
        self.wechat_accounts.of_primary.first || self.wechat_accounts.try(:first)
    end

    # 价格
    DEFAULT_PER_STORE_COST  = 3800
    DEFAULT_MINI_PRICE      = 2880
    DEFAULT_STANDARD_PRICE  = 8680
    DEFAULT_MULTIPLE_PRICE  = 36000
    DEFAULT_CHAIN_START_NUM = 3
    DEFAULT_CHAIN_START_PRICE = 36000
    DEFAULT_PRINTER_CODE_PRICE = 100
    DEFAULT_BASE_PRICE      = 0


    def upgrade_shop_to(new_feature_module_group_str, max_branches_limit, expired_at, skip_check = nil)
      if skip_check.present? || Ddt::FeatureModuleGroup.can_upgrade_to?(self, max_branches_limit, new_feature_module_group_str)
        Ddt::FeatureModulesConfig.transaction do
            fmg = Ddt::FeatureModuleGroup.send(new_feature_module_group_str.to_sym)
            fmg[:modules].each do |fm|
                fmc = shop.feature_modules_configs.where(:feature_module => fm).first_or_initialize
                if fmc.expired_at.nil? || fmc.expired_at < expired_at
                    fmc.expired_at = expired_at
                end
                puts "#{fmc.id}: #{fmc.feature_module} in shop #{shop.slug}"
                fmc.save!
            end
            self.update_attributes!(
                :shop_type => new_feature_module_group_str,
                :max_branches_limit => max_branches_limit,
                :expiration_time => expired_at)
        end
      else
        raise '升级策略不允许'
      end
    end

    # 单门店
    def single_branch?
        self.max_branches_limit == 1
    end

    # 多门店
    def multi_branch?
        self.max_branches_limit > 1
    end

    def label
      "#{self.name}-#{self.slug}"
    end

    def shop_type_name
      Ddt::FeatureModuleGroup.send(self.shop_type.to_sym)[:label]
    end

    def enable_foreign_currency_name
      self.enable_foreign? ? I18n.t("enabled") : I18n.t("disabled")
    end

    def currency
      self.enable_foreign? ? (self.foreign_currency_symbol.presence || '￥') : '￥'
    end

    def time_zone
      self.enable_foreign? ? (self.foreign_time_zone || Time.zone.name) : Time.zone.name
    end

    def splited_search_words
      self.search_words.gsub(/\s+/m, ' ').gsub(/^\s+|\s+$/m, '').split(" ") rescue []
    end

    def current_alipay_method
      self.payment_methods.where(type: 'Ddt::AlipayMethod').active.first
    end

    def current_wechatpay_method
      self.payment_methods.where(type: 'Ddt::WechatpayMethodLegacy').active.first ||
      self.payment_methods.where(type: 'Ddt::WechatpayMethodV336').active.first
    end

    def current_baidupay_method
      self.payment_methods.where(type: 'Ddt::BaidupayMethod').active.first
    end

    def prior_wechatpay_method(require_active = false)
      method = self.wechatpay_method_v336 # the default wechatpay method
      unless method.active
        v27_method = self.wechatpay_method_legacy
        method = v27_method if v27_method.active
      end

      if require_active and not method.active
        nil
      else
        method
      end
    end

    def boss
      self.accounts.boss
    end

    def creator
      self.accounts.where(built_in: true).first
    end

    def select_json
      { id: self.id, name: "#{self.slug}-#{self.name}" }
    end

    def introduction_decoder
      ::HTMLEntities.new.decode(ActionView::Base.full_sanitizer.sanitize(self.introduction))
    end

    def shop_id
      self.id
    end

    def shop
      self
    end

    def notify_to(user, article_options={})
      Ddt::ShopWeixinNotifyActionWorker.perform_in(1.second, user.id, article_options)
      # Ddt::ShopWeixinNotifyActionWorker.new.perform( user.id, article_options)
    end

    delegate :use_sms?, :can_use_validation_sms?, :can_use_order_sms?, to: :short_message_setting

    def recharge_short_messages(count)
      self.short_message_setting.recharge(count)
    end

    # scope :shop_access_times_of_today, ->(shop){
    #   Impression.where("DATE_FORMAT(CONVERT_TZ(created_at,'+00:00','+08:00'), '%Y-%m-%d') = ? and impressionable_type = 'Shop' and impressionable_id = ? ", Time.now.localtime.strftime('%Y-%m-%d'), shop.id)}
    # scope :distinct_users, ->{select('distinct(user_id)')}

    def pay_method_can?(order_type, pay_method)
      self.send("#{order_type}_pay_method_setting").send("can_#{pay_method}?")
    end

    def send_birthday_sms_to_vips
      sms_body = short_message_setting.birthday_message
      vips = birthday_vips(advance_days: 0)
      vips.uniq.each do |vip|
        sms = Ddt::ShortMessage.wrap_birthday_message_to_send(self, vip.phone, sms_body)
        sms.save
      end
    end

    def send_birthday_promotion(advance_days: 0)
      vips = birthday_vips(advance_days: advance_days)
      year = Time.now.year.to_s
      vip_birthdays=[]
      vips.uniq.find_each do |vip|
        vip_birthdays << Ddt::Promotion::Events::VipBirthday.new(user: vip.user, uuid: SecureRandom.uuid)
      end
      Ddt::Promotion::Events::VipBirthday.import(vip_birthdays)
      vips = Ddt::PromotionEvent.where(uuid: vip_birthdays.map(&:uuid))
      vips.each do |v|
        v.send :handle_promotion
      end

    end

    def birthday_vips(advance_days: 0)
      date = (Time.zone.now + advance_days.day).strftime('%m-%d')
      date_y = (Time.zone.now + advance_days.day).strftime('%Y-%m-%d')
      yesterday = (Time.now - 1.days).strftime('%Y-%m-%d')
      this_year = (Time.now - 1.days).strftime('%Y-')
      vip_infos.not_default_level.where(
        "phone IS NOT NULL AND birthday IS NOT NULL 
         AND ( DATE_FORMAT(birthday, '%m-%d')=:date or 
               ( DATE_FORMAT(ddt_vip_infos.become_vip_at, '%Y-%m-%d')=:yesterday
                 AND concat(:this_year, DATE_FORMAT(birthday,'%m-%d'))>=:yesterday
                 AND concat(:this_year, DATE_FORMAT(birthday,'%m-%d'))<:date_y
               )
             )",
         this_year: this_year, date: date, yesterday: yesterday, date_y: date_y)
    end

    # 只允许过期前一个月充值
    def in_recharge_time_range?
      (self.expiration_time - 1.month) < Time.now
    end

    def backend_waiting_users_path
      "/backend/shops/#{self.slug}/vip_infos/applying"
    end

    def is_give_up_name
      self.is_give_up? ? '放弃跟进' : '正常跟进'
    end

    def set_is_suspicious(phone_address)
      if phone_address.blank? || self.address.blank? || self.agent_no.present?
        self.is_suspicious = false
      else
        self.is_suspicious = !Cncity.same_city?(phone_address, self.address)
      end
    end

    def calculate_tax(total)
      self.enable_foreign? ? total * self.foreign_tax_rate : 0.0
    end

    def pay_on_face_pay_method
      self.pay_methods.where(name_sym: :pay_on_face).first
    end

    def deliveryman_locations(deliverymans)
      if deliverymans.present?
        Ddt::Location
            .where(owner_id: deliverymans.map(&:id), owner_type: 'Ddt::Account')
            .where("updated_at > ?", 10.minutes.ago)
            .select(:id, :owner_id, :owner_type, :longitude, :latitude, :updated_at)
      else
        return []
      end
    end

    def branches_select_json(range_branches, all_branch_ids)
      json = []
      json << {id: all_branch_ids, name: '所有门店'} if all_branch_ids.present?
      branch_groups.each do |group|
        json << {id: group.branch_ids.join(','), name: group.name}
      end
      json.concat(range_branches.map(&:select_json))
    end

    def feature_module_names
      @feature_module_names ||= self.feature_modules_configs.available.enabled.map{|it| it.feature_module.try(:to_sym)}
    end

    def features
      FeatureModules.features(self.feature_module_names)
    end

    def has_module?(key)
      feature_module_names.include? key.to_sym
    end

    def has_feature?(key)
      fmcs = qualified_feature_modules_configs(key)
      fmcs.present? && fmcs.length > 0
    end

    def qualified_feature_modules_configs(key)
      @qualified_feature_modules_configs ||= self.feature_modules_configs.available.select do |feature_modules_config|
        FeatureModules.get(feature_modules_config.feature_module.to_sym)[:features].include?(key.to_sym)
      end
    end

    private

    def generate_slug
      unless self.slug.present?
        len = 3
        slug = SecureRandom.hex len
        while Shop.where(slug: slug).present?
          len += 1
          slug = SecureRandom.hex len
        end
        self.slug = slug
      end
    end

    def assign_city_code
      if self.city_code.nil? || address_changed?
        self.city_code = Cncity.get_city_code(self.address)
      end
    end

    def record_updated_sale_employee_at
      if self.sale_employee_id_changed? && self.sale_employee_id.present?
        touch :updated_sale_employee_at
        self.update_column(:pre_sale_staff_id, nil)
      end
    end

    def record_updated_pre_sale_staff_at
      touch :updated_pre_sale_staff_at if self.pre_sale_staff_id_changed?
    end

    def set_agent_no
      return if agent_no.present?
      agent = Ddt::AgentZone.get_exclusive_agent(self.city_code)
      if agent.present?
        self.update_column(:agent_no, agent.agent_no)
      end
    end

    def create_feature_modules_configs
      Ddt::FeatureModuleGroup.send(self.shop_type)[:modules].each do |fm|
        self.feature_modules_configs.create!(feature_module: fm, expired_at: self.expiration_time)
      end
    end
  end
end
