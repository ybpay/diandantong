module Ddt
  class Account < Ddt::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    # :async
    attr_accessor :terms
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :lockable, :authentication_keys => [:login]
    has_and_belongs_to_many :roles, join_table: "ddt_accounts_roles"
    validates_acceptance_of :terms, on: :create

    ##### relationship
    include Ddt::CommentOwner
    include Discard::Model
    default_scope { kept }


    belongs_to :shop, class_name: 'Ddt::Shop'
    def shop
      TCC.fetch("shop.#{self.shop_id}") {super}
    end
    has_many :coupons_of_applied, class_name: 'Ddt::BaseCoupon', as: :operator
    accepts_nested_attributes_for :shop
    has_many :manageships, dependent: :destroy, class_name: 'Ddt::Manageship', inverse_of: :account
    has_many :manage_branches, through: :manageships, source: :branch
    has_and_belongs_to_many :products, :join_table => 'ddt_accounts_products', class_name: 'Ddt::Product'
    has_and_belongs_to_many :categories, :join_table => 'ddt_accounts_categories', class_name: 'Ddt::Category'
    ids_string_for :manage_branches, :roles, :products, :categories
    belongs_to :user, class_name: 'Ddt::User'
    has_many :locations, dependent: :delete_all, class_name: 'Ddt::Location', as: :owner
    # has_many :baidu_push_channels, class_name: 'Ddt::BaiduPushChannel'
    has_many :push_channels, class_name: 'Ddt::PushChannel'
    has_many :shifts, class_name: "Ddt::Shift"
    has_one :notification_receive_setting, class_name: "Ddt::NotificationReceiveSetting"
    has_many :system_messages

    delegate :user_open_id, to: :user, allow_nil: true

    #####validations
    validates :name, length: {maximum:50}

    validates_presence_of   :email
    validates_uniqueness_of :email, :allow_blank => true, scope: :discarded_at, :if => :email_changed?
    validates_format_of     :email,    :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?

    validates_presence_of     :password, :on=>:create
    validates_confirmation_of :password, :on=>:create
    validates_length_of       :password, :within => Devise.password_length, :allow_blank => true

    validates :login_id, presence: true, uniqueness: { case_sensitive: false, scope: :discarded_at}, login_id: true
    validates :shop_id, presence: true, unless: :is_admin?
    validates :phone, presence: true , uniqueness: {:scope=>[:discarded_at, :built_in]}, if: :built_in?
    validates :phone, length: 3..20, unless: "is_admin? or (shop && shop.enable_foreign)"
    validate :check_captcha_valid, on: :create
    validate :allow_to_change_password, on: :update
    validate :must_accept_term, on: :create

    #####callback
    before_validation :change_login_id, if: :need_change_login_id
    before_destroy do
      raise "can not destroy builtin account" if self.built_in?
    end
    before_create :set_term_version
    after_create :set_captcha_validated
    after_create :create_notification_receive_setting

    Role.types.each do |role_type|
      role_class_name = "Ddt::Role::#{role_type.to_s.camelize}"
      scope role_type.to_s.pluralize, ->{ includes(:roles).where(ddt_roles: { type: role_class_name }).references(:ddt_roles) }
      define_method "is_#{role_type}?" do
        is_role_name = "@is_#{role_type}"
        if instance_variable_defined?(is_role_name)
          instance_variable_get(is_role_name)
        else
          instance_variable_set(is_role_name, self.roles.any?{|role| role.type == role_class_name.to_s})
        end
      end
    end
    scope :bosses_and_workers, -> {includes(:roles).where(ddt_roles: { type: ["Ddt::Role::Boss", "Ddt::Role::Worker"] }).references(:ddt_roles) }
    scope :boss, ->{ bosses }
    scope :deliverymans, ->{ deliverymen }
    scope :of_shop_id, ->(shop_id) { where(:shop_id => shop_id)}

    # 弥补权限定义中的账户查询条件
    scope :manage_by_worker, ->(worker){
      includes(:roles, :manage_branches).where("(ddt_roles.type in (:roles) or ddt_roles.builtin=0 or ddt_accounts.id = :account_id) and ddt_branches.id in (:branch_ids)",
        roles: %W[
            Ddt::Role::Deliveryman
            Ddt::Role::Chef
            Ddt::Role::Cook
            Ddt::Role::Cashier
            Ddt::Role::Waiter
            Ddt::Role::Accountant
          ],
        account_id: worker.id,
        branch_ids: worker.manage_branch_ids).references(:roles, :manage_branches)
    }

    #####accessor
    attr_accessor :login
    attr_accessor :captcha
    attr_accessor :captcha_valid

    after_save :update_shop_phone_if_need

    #
    # create account, share by oapi and registration
  #
    def init(sign_up_params, track_from:)

      unless self.captcha_valid
        self.errors.add(:captcha_valid, "不正确")
        return false
      end
      transaction do
        agent_no = Ddt::Agent.find_by(:agent_no => sign_up_params[:shop_attributes][:agent_no]).agent_no rescue nil
        shop = Ddt::Shop.new(
            agent_no: agent_no,
            shop_type: sign_up_params[:shop_attributes][:shop_type]||Ddt::Shop::DEFAULT_SHOP_TYPE,
            slug: sign_up_params[:login_id],
            telephone: sign_up_params[:phone],
            expiration_time: DateTime.now+7.days,
            address: sign_up_params[:shop_attributes][:address],
            track_from: track_from
        )
        self.ban_login_app_when_no_open = false
        self.phone_address = self.look_up_phone_address
        shop.set_is_suspicious(self.phone_address)
        shop.save
        self.shop = shop
        self.built_in = true
        result = self.save
        raise ActiveRecord::Rollback unless result
        result
      end


    end


    def update_shop_phone_if_need
      return unless self.built_in
      return unless phone_changed?
      self.shop.update_column(:phone, self.phone)
    end

    def reset_msg_count
      self.update_attribute(:unread_msg_count, self.system_messages.of_unread.count)
    end

    def comment_owner_label
      name
    end

    def managed_branches
      self.is_boss? ? self.shop.branches : self.manage_branches
    end

    def managed_branch_ids
      self.is_boss? ? self.shop.branch_ids : self.manage_branch_ids
    end

    def any_branch_in_service?
      if self.is_boss?
        query_params = {shop_id: self.shop_id}
      else
        query_params = {shop_id: self.shop_id, id: self.manage_branch_ids}
      end
      Ddt::Branch.where(query_params).open_on_today.of_in_service.count > 0
    end

    def self.to_csv(accounts, options)
      CSV.generate(options) do |csv|
        csv << [ "账号名称", "短称", "手机", "姓名", "邮箱", "注册时间", "过期时间或剩余订单数", "地址", "来源"]
        accounts.each do |account|
          shop = account.shop
          csv << [shop.name, shop.slug, account.phone, account.name, account.email,  shop.created_at.strftime("%F %T"),  shop.expiration_time.strftime("%Y-%m-%d"), shop.address, shop.track_from_name]
        end
      end
    end

    def self.find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions.to_h).where(["lower(login_id) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions.to_h).first
      end
    end

    def self.current= (account)
      RequestStore.store[:current_account] = account
    end

    def self.current
      RequestStore.store[:current_account]
    end

    def to_label
      self.name
    end

    def select_json
      { id: id, name: name }
    end

    def update_push_channel(options)
      return if options[:channel_id].blank?
      channel = Ddt::PushChannel.unscoped.where(
          j_push_channel_id: options[:channel_id]
      ).first
      if channel.blank?
        channel = self.push_channels.build
      end
      channel.account_id = self.id
      channel.j_push_channel_id = options[:channel_id] if options[:channel_id].present?
      channel.os_type = options[:os_type] if options[:os_type].present?
      channel.is_oem =  options[:is_oem]
      channel.expired_at = 30.days.since
      channel.save!
    end

    def no_concern_order?
      roles.size == 1 && ([Ddt::Role::VipInfoManager, Ddt::Role::QueueWaiter].include? roles[0].class)
    end

    # 取出订单里厨师关心的内容(确认时)
    def concern_in_confirm(order)
      litps = []
      logs = order.order_change_logs.place_and_append
      logs.each do |log|
        litps << concern_litps_in_log(log)
      end
      litps.flatten.compact
    end

    #取消时
    def concern_in_cancel(order)
      cancel_log = order.order_change_logs.cancel_log
      concern_litps_in_log(cancel_log)
    end

    # 追加时
    def concern_in_append(order)
      append_log = order.order_change_logs.last_append_log
      concern_litps_in_log(append_log)
    end

    # 退菜时
    def concern_in_delete(order)
      delete_log = order.order_change_logs.last_delete_log
      concern_litps_in_log(delete_log)
    end

    def concern_litps_in_log(log)
      litps = log.line_item_trace_points
      litps.select { |p| p.in_white_list?(concern_product_ids) }
    end

    def concern_product_ids
      @concern_product_ids ||= [self.product_ids, self.categories.product_ids_with_sub].flatten.uniq
    end

    def concern_variant_ids
      @concern_variant_ids ||= Variant.where(product_id: concern_product_ids).pluck(:id)
    end

    def login_main_id
      self.login_id.split(':', 2)[0]
    end

    def login_sub_id
      built_in? ? nil : self.login_id.split(':',2)[1]
    end

    def bind_by_code(code)
      appid = Ddt::WeixinConfig.webauth.app_id
      app_secret = Ddt::WeixinConfig.webauth.app_secret
      unionid = Ddt::WeixinApi.fetch_oauth_access_token(appid, app_secret, code)[:unionid]
      system_wechat_account = Ddt::WechatAccount.system_wechat_account
      unique_user = Ddt::UniqueUser.find_by(unionid: unionid, gonghao_open_id: system_wechat_account.gonghao_open_id)
      return false if unique_user.blank?
      user = unique_user.users.where(shop_id: system_wechat_account.shop_id).first
      return false if user.blank?
      self.update_column(:user_id, user.id)
      true
    end

    def bind_by_user_id(user_id)
      system_wechat_account = Ddt::WechatAccount.system_wechat_account
      user = Ddt::User.find_by(shop_id: system_wechat_account.shop_id, id: user_id)
      return false if user.blank?
      system_user = Ddt::User.includes(:wechat_users).where(shop_id: system_wechat_account.shop_id, unique_user_id: user.unique_user_id, ddt_wechat_users: { gonghao_open_id: system_wechat_account.gonghao_open_id, unsubscribed_at: nil }).first
      return false if system_user.blank?
      self.update_column(:user_id, user_id)
      true
    end

    def look_up_phone_address
      return nil if self.phone.blank?
      result = (Ddt::JuheApi.mobile_address(Ddt::WeixinConfig.juhe.app_key_mobile_address, self.phone) rescue nil)
      return nil if result.nil?
      Cncity.suffix result[:province], result[:city]
    end

    concerning :AuthenticationToken do
      included do
        after_create :refresh_authentication_token
      end

      def authentication_token_expired?
        authentication_token_expired_at < Time.now
      end

      def refresh_authentication_token
        self.authentication_token = generate_authentication_token
        self.authentication_token_expired_at = 1.week.since
        save!
        authentication_token
      end

      private
      def generate_authentication_token
        loop do
          token = Devise.friendly_token
          break token unless Account.where(authentication_token: token).first
        end
      end
    end

    concerning :CheckPermission do
      def all_permissions
        Role.merged_permissions(self.roles)
      end

      def can?(scope, target, action, options={})
        return true if is_admin?
        return false if roles.blank?
        case scope.to_sym
        when :shop
          roles.any?{|role| role.can?(scope, target, action)}
        when :branch
          branch_id = options[:branch_id] || managed_branch_ids.first
          managed_branch_ids.include?(branch_id.try(:to_i)) && roles.any?{|role| role.can?(scope, target, action)}
        end
      end

      def authorize!(scope, target, action, options={})
        unless can?(scope, target, action, options)
          raise Error::NoPermissionError.new(Permission.new(scope, target, action, options))
        end
      end
    end

    def shipping_order_count
      Ddt::Shipment.where(state: [:pending, :shipping], delivery_man_id: self.id).count
    end

    private
    def change_login_id
      login_id_str = self.login_id.split(":").last
      if login_id_str == shop.slug
        self.login_id = login_id_str
      else
        self.login_id = "#{shop.slug}:#{login_id_str}"
      end
    end

    def can_not_change_role_of_self(role)
      if Ddt::Account.current.present? && Ddt::Account.current.id == self.id
        self.errors.add(:role_ids, "不允许改变自己的角色")
        raise ActiveRecord::Rollback
      end
    end

    def allow_to_change_password
      if Ddt::Account.current.present? && self.changes[:encrypted_password].present?
        # if Ddt::Account.current.id == self.id
        #   debugger
        #   unless Ddt::Account.current.valid_password? self.current_password
        #     self.errors.add(:base, "不允许重置自己的密码")
        #   end
        if Ddt::Account.current.id != self.id && !(Ddt::Account.current.is_admin? or Ddt::Account.current.is_boss?)
          self.errors.add(:base, "无权修改该账户的密码")
        end
      end
    end

    def check_captcha_valid
      self.errors.add(:captcha, "不正确") unless self.captcha_valid
    end

    def set_captcha_validated
      if self.captcha_valid && self.captcha.present?
        captcha = Ddt::SmsCaptcha.find(self.captcha)
        captcha.validate! if captcha.present?
      end
    end

    def must_accept_term
      unless accept_term
        self.errors.add(:accept_term, "必须同意使用协议")
      end
    end

    def need_change_login_id
      self.shop.present? and (self.login_id != self.shop.slug)
    end

    def set_term_version
      self.term_version = Ddt::EULA::LATEST_VERSION
    end

  end
end
