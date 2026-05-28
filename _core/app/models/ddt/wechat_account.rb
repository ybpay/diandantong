# encoding: utf-8
module Ddt
  class WechatAccount < Ddt::Base

    auto_strip_attributes :app_id, :app_secret, :gonghao_open_id, :access_token, :jsapi_ticket, :weixin_hao

    DEFAULT_HELP_MSG = "以下是本微信公众账号的使用说明:\n回复0:获得使用帮助\n回复1:获得点餐链接\n回复2:获得当前的促销活动\n回复3:获得最近历史订单\n回复4:查询我的会员信息\n点击+发送位置:获得最近的商铺\n留言请发送'@+留言内容'"

    GONGHAO_SUBSCRIBE = 'gonghao_subscribe'
    GONGHAO_SERVICE = 'gonghao_service'

    acts_as_type :gonghao_type, [GONGHAO_SUBSCRIBE, GONGHAO_SERVICE], %W[订阅号 服务号]
    TYPES = gonghao_type_collection_hash


    belongs_to :shop, class_name: 'Ddt::Shop', touch: true
    belongs_to :default_branch, class_name: 'Ddt::Branch'

    has_many :wechat_menus, class_name: 'Ddt::WechatMenu'
    has_many :wechat_template_ids, class_name: 'Ddt::WechatTemplateId'

    has_many :apply_device_logs, class_name: 'Ddt::ShakeAround::ApplyLog'
    has_many :devices, class_name: 'Ddt::ShakeAround::Device'
    has_many :pages, class_name: '::Ddt::ShakeAround::Page', foreign_key: :wechat_account_id
    has_many :shake_infos, class_name: 'Ddt::ShakeAround::ShakeInfo'
    has_many :keywords_third_party_interfaces, class_name: 'Ddt::KeywordsThirdPartyInterface'
    include Ddt::Attachable
    attachable_one :server_auth_file

    preference :auth_info, :text
    preference :authorizer_info, :text

    # validates_presence_of :public_account_name, :gonghao_open_id, :token
    # validates_presence_of :app_id, :app_secret, on: :create
    # validates :gonghao_open_id, gonghao: true, :uniqueness=>{:scope=>:shop_id}
    validate :check_appid_appsecret, if: :need_check_token?

    scope :of_primary, -> {where(:is_primary => true)}

    attr_accessor :username, :password
    before_save :set_token_nil, if: :need_expire_token?
    after_save :config_as_primary

    def wechat_users
      self.shop.wechat_users.where(:gonghao_open_id => self.gonghao_open_id)
    end

    def self.system_wechat_account
      self.find_by(
        gonghao_open_id: Ddt::WeixinConfig.gonghao.open_id,
        app_id:          Ddt::WeixinConfig.gonghao.app_id,
        app_secret:      Ddt::WeixinConfig.gonghao.app_secret)
    end

    def self.system_wechat_account_access_token
      self.system_wechat_account.get_access_token
    end

    def system_keywords
      Ddt::Event::system_keyword_collection
    end

    def custom_wechat_menus_hash
      { button: self.wechat_menus.root_menus.map(&:to_menu_hash) }
    end

    def sync_custom_wechat_menu_to_wechat
      if self.wechat_menus.present?
        WeixinApi.create_custom_menu(get_access_token, custom_wechat_menus_hash)
      else
        WeixinApi.delete_custom_menu(get_access_token)
      end
    rescue WeixinApi::WeixinApiError => e
      [false, e.errmsg]
    end

    def can_define_menu?
      if is_authorized?
        account_service? || account_verified?
      else
        app_id.present? && app_secret.present?
      end
    end

    def human_account_name
      "#{self.account_name} (#{self.gonghao_open_id})"
    end

    def is_primary_name
      is_primary ? '主公众号' : '普通公众号'
    end

    def get_access_token
      if is_authorized?
        self.get_authorizer_access_token
      else
        if self.access_token.present? && self.last_update_access_token_at.present? && self.last_update_access_token_at > 2.hours.ago
          self.access_token
        else
          new_access_token = WeixinApi.fetch_access_token(self.app_id, self.app_secret)
          if new_access_token.present?
            self.access_token = new_access_token
            self.last_update_access_token_at = DateTime.now
            self.save(validate: false)
          end
          new_access_token
        end
      end
    end

    def get_template_id(template_id_short)
      Ddt::WechatTemplateId.get_template_id(self, template_id_short)
    end

    def get_jsapi_ticket
      if self.jsapi_ticket.present? && self.last_update_jsapi_ticket_at.present? && self.last_update_jsapi_ticket_at > 2.hours.ago
        self.jsapi_ticket
      else
        temp_access_token = self.get_access_token
        new_jsapi_ticket = WeixinApi.fetch_jsapi_ticket(temp_access_token)
        if new_jsapi_ticket.present?
          self.jsapi_ticket = new_jsapi_ticket
          self.last_update_jsapi_ticket_at = DateTime.now
          self.save(validate: false)
        end
        new_jsapi_ticket
      end
    end

    # for auth account
    def update_authorizer_info
      component = WechatComponent.instance
      data = WeixinApi.get_authorizer_info(component.get_component_access_token, component.component_appid, self.authorizer_appid)
      authorizer_info = data[:authorizer_info].to_options
      self.update!({
          qrcode_url: data[:qrcode_url],
          nick_name: authorizer_info[:nick_name],
          head_img: authorizer_info[:head_img],
          service_type_info: authorizer_info[:service_type_info]['id'],
          verify_type_info: authorizer_info[:verify_type_info]['id'],
          user_name: authorizer_info[:user_name],
          gonghao_open_id: authorizer_info[:user_name],
          preferred_authorizer_info: data.to_s
        })
    end

    def get_authorizer_access_token
      if self.authorizer_access_token.present? && self.authorizer_access_token_expired_at.present? && self.authorizer_access_token_expired_at > Time.now
        self.authorizer_access_token
      else
        component = WechatComponent.instance
        data = WeixinApi.refresh_authorizer_access_token(component.get_component_access_token, component.component_appid, self.authorizer_appid, self.authorizer_refresh_token)
        self.update!({
          authorizer_access_token: data[:authorizer_access_token],
          authorizer_access_token_expired_at: data[:expires_in].seconds.from_now,
          authorizer_refresh_token: data[:authorizer_refresh_token]
        })
        data[:authorizer_access_token]
      end
    rescue WeixinApi::WeixinApiError => e
      self.delay.send_refresh_authorizer_access_token_error_email(e)
      raise Ddt::KnownException.wrap(e)
    end

    # 取消授权
    def cancel_authorize
      self.destroy
    end

    def is_authorized_name
      is_authorized? ? '已授权' : '未授权'
    end

    def account_name
      is_authorized? ? nick_name : public_account_name
    end

    def account_appid
      is_authorized? ? authorizer_appid : app_id
    end

    def account_verified?
      # verify_type_info 授权方认证类型，-1代表未认证，0代表微信认证，1代表新浪微博认证，2代表腾讯微博认证，3代表已资质认证通过但还未通过名称认证，4代表已资质认证通过、还未通过名称认证，但通过了新浪微博认证，5代表已资质认证通过、还未通过名称认证，但通过了腾讯微博认证
      is_authorized? ? (verify_type_info != -1) : be_verified
    end

    def account_verified_name
      account_verified? ? '已认证' : '未认证'
    end

    def account_service?
      # service_type_info 授权方公众号类型，0代表订阅号，1代表由历史老帐号升级后的订阅号，2代表服务号
      is_authorized? ? (service_type_info == 2) : is_gonghao_service?
    end

    def account_verified_service?
      account_verified? && account_service?
    end

    def account_service_name
      account_service? ? '服务号' : '订阅号'
    end

    private
    def need_check_token?
      app_id_changed? || app_secret_changed?
    end

    def check_appid_appsecret
      WeixinApi.fetch_access_token(self.app_id, self.app_secret)
    rescue WeixinApi::WeixinApiError => e
      errors.add(:base, I18n.t('invalid app_id or app_secret'))
    end

    def need_expire_token?
      return gonghao_open_id_changed? || app_id_changed? || app_secret_changed? || token_changed?
    end

    def set_token_nil
      self.jsapi_ticket = nil
      self.last_update_access_token_at = nil
      self.last_update_jsapi_ticket_at = nil
      self.access_token = nil
    end

    def config_as_primary
      if self.is_primary_changed? && self.is_primary?
        self.shop.wechat_accounts(:reload).where.not(id: self.id).update_all(:is_primary => false)
      end
    end

    # send error email
    def send_appid_or_appsecret_error_email(e=nil)
      shop = self.shop
      ac = shop.accounts.first
      ck = "fetch_weixin_access_token_invalid_#{app_id}_notification_at"
      last_notification_at = Rails.cache.fetch(ck) do
        1.days.ago # 默认值使发送邮件触发
      end
      # 每 30 分钟发送一封
      if last_notification_at < 30.minutes.ago
        body = <<-EMAILBODY
您的公众号#{self.public_account_name}获取access_token失败。
微信返回的错误信息：#{e.message if e.present?}
当前配置信息点击以下链接到到点单通后台查询。
#{Ddt::Core::Engine.routes.url_helpers.backend_shop_wechat_account_url(shop, self, host: Rails.application.default_url_options[:host])}
        EMAILBODY
        NotificationMailer.notify(ac.email, "您的公众号#{self.public_account_name}获取微信access_token失败",body, shop).deliver
        Rails.cache.write(ck, Time.now)
      end
    end

    def send_refresh_authorizer_access_token_error_email(e=nil)
      # 给商家发邮件
      shop = self.shop
      ac = shop.accounts.first
      ck = "refresh_authorizer_access_token_invalid_#{app_id}_notification_at"
      last_notification_at = Rails.cache.fetch(ck) do
        1.days.ago # 默认值使发送邮件触发
      end
      # 每 30 分钟发送一封
      if last_notification_at < 30.minutes.ago
        body = <<-EMAILBODY
您的公众号#{self.public_account_name}刷新授权信息失败。
微信返回的错误信息：#{e.message if e.present?}
当前配置信息点击以下链接到到点单通后台查询。
#{Ddt::Core::Engine.routes.url_helpers.backend_shop_wechat_accounts_url(shop, host: Rails.application.default_url_options[:host])}
请尝试删除该公众号并重新选择一键授权
        EMAILBODY
        NotificationMailer.notify(ac.email, "您的公众号#{self.public_account_name}刷新授权信息失败",body, shop).deliver
        Rails.cache.write(ck, Time.now)
      end
    end
  end
end
