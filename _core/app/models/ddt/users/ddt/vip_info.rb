# encoding:utf-8
require 'bcrypt'
require 'rqrcode_png'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/html_outputter'
module Ddt
  class VipInfo < Ddt::Base
    include Discard::Model
    default_scope { kept }

    include Ddt::BelongsToShopWithTouch
    include Ddt::VipInfoImportExport
    include BCrypt
    ### relationships
    attr_accessor :pay_password
    belongs_to :vip_level, counter_cache: true, class_name: 'Ddt::VipLevel'
    has_many :base_users, class_name: 'Ddt::BaseUser'
    has_one :user, ->{user}, class_name: 'Ddt::BaseUser'
    belongs_to :source_user, ->{user}, class_name: 'Ddt::BaseUser'
    has_one :phone_user, ->{phone_user}, class_name: 'Ddt::BaseUser', dependent: :destroy
    # has_one :web_user, ->{web_user}, class_name: 'Ddt::BaseUser'
    acts_as_type :sex, [:male, :female], %W[先生 女士]
    has_one :card_wallet, as: :owner, class_name: 'Ddt::UserCardWallet'
    has_one :credits_wallet, as: :owner, class_name: 'Ddt::UserCreditsWallet'
    include Ddt::CarrierWaveBridge
    mount_uploader :avatar, AvatarImageUploader
    has_many :short_messages, class_name: 'Ddt::ShortMessage', as: :owner

    ### validations
    validates :placed_orders_count, :total_amount, presence: true
    validates :vip_no, presence: true, uniqueness: { scope: [:shop_id, :deleted_at]}
    validates :pay_password, password: true, allow_blank: true
    validates_presence_of :vip_level#, :name, :phone, :pay_password_hash
    validates_presence_of :name, :phone, unless: :builtin?
    valid_phone :phone
    validates :phone, uniqueness: { scope: [:shop_id, :deleted_at], unless: ->{ builtin? && phone.nil? } }

    before_create :create_wallets
    before_create :create_default_password
    after_save :check_auto_upgrade, if: :total_amount_changed?
    after_save :fill_base_users_msg

    has_many_orders :orders
    has_many_orders :active_orders,      ->{ active }
    has_many_orders :delivery_orders,    ->{ delivery }
    has_many_orders :reservation_orders, ->{ reservation }
    has_many_orders :eat_in_hall_orders, ->{ eat_in_hall }
    has_many_orders :fastfood_orders,    ->{ fastfood }
    has_many_orders :groupon_orders,     ->{ groupon }
    has_many_orders :recharge_orders,    ->{ recharge }
    has_many_orders :payment_orders,     ->{ payment }

    # scopes
    scope :not_verified, ->{ where(is_verified: false)}
    scope :verified, ->{ where(is_verified: true)}
    scope :not_default_level, ->{ includes(:vip_level).where(ddt_vip_levels: { is_default: false })}
    scope :not_bind_wechat_user, -> {
      joins("LEFT JOIN ddt_base_users ON ddt_base_users.vip_info_id = ddt_vip_infos.id").
      where("(ddt_base_users.id IS NULL || ddt_base_users.id IS NOT NULL AND ddt_base_users.type != 'Ddt::User') AND ddt_vip_infos.phone IS NOT NULL")
    }
    scope :builtin, ->(is_builtin=true){ where(builtin: is_builtin)}
    scope :applying, ->{where(is_apply_vip: true)}
    scope :by_applying, ->(bool=nil){ where(is_apply_vip: (bool==true || bool=="true")) unless (bool.nil? || bool=="false")}
    scope :blocked, ->(bool=nil){ includes(:user).where(ddt_base_users: { is_blocked: (bool==true || bool=="true")}) unless (bool.nil? || bool=="false")}
    scope :has_wechat_user, ->(bool=nil){ includes(:user).where.not(ddt_base_users: { id: nil}) unless (bool.nil? || bool=="false")}
    scope :order_within_days, ->(n){
      n = Integer(n)
      where(last_placed_at: n.days.ago.beginning_of_day..Time.now)
    }
    scope :become_within_days, ->(n){
      n = Integer(n)
      where(created_at: n.days.ago.beginning_of_day..Time.now)
    }

    def authenticate(password)
      if self.pay_password_hash.blank?
        password.blank?
      else
        Password.new(self.pay_password_hash) == password
      end
    end

    def pay_password=(new_value)
      @pay_password = new_value
      if @pay_password.present?
        self.pay_password_hash = Password.create(@pay_password, :cost => 5)
      end
    end

    def is_vip?
      !self.is_default
    end

     # add scope search for ransack
    def self.ransackable_scopes(auth_object = nil)
      [:order_within_days, :by_applying, :blocked, :has_wechat_user]
    end

    def password_not_set
      self.pay_password_hash.blank?
    end

    def base_user
      self.base_users.first
    end

    def friendly_vip_level_discount
      # 该值只是用来显示，5折显示为5
      vip_level.discount * 10
    end

    def select_json
      {id: id, name: to_label}
    end

    def to_label
      [self.name, self.vip_no].join(" ")
    end

    def get_price_of_itemable(itemable)
      if [Ddt::Variant, Ddt::VariantPackage, Ddt::ComboPackage].include?(itemable.class) && itemable.enable_discount? && !self.vip_level.is_default
        [itemable.price, (itemable.vip_price rescue nil)].compact.min
      else
        itemable.price
      end
    end

    def self.random_vip_no(shop)
      count = shop.vip_infos.count
      length = 5
      loop do
        vip_no = Random.rand((10 ** (length-1)) * 9 - 1) + 10 ** (length-1)
        if !shop.vip_infos.exists?(vip_no: vip_no.to_s)
          break vip_no
        else
          if( count > (10 ** length)/2 )
            length += 1
          end
        end
      end
    end

    def check_auto_upgrade
      new_vip_level = {
        upgrade_recharge_money: :total_recharge_money,
        upgrade_total_amount:   :total_amount,
        upgrade_get_credits:    :total_get_credits,
      }.map {|condition_value, current_value|
        self.shop.vip_levels.auto_upgrade_levels.where.not({condition_value => nil}).reorder({condition_value => :desc}).detect{|level| self.send(current_value) >= level.send(condition_value)}
      }.uniq.compact.sort{|a, b| b.level <=> a.level }.first
      self.update_column(:vip_level_id, new_vip_level.id) if new_vip_level.present? && self.vip_level != new_vip_level && self.vip_level.discount >= new_vip_level.discount
    end

    def apply_vip(from_branch_id: nil)
      transaction do
        self.update(is_apply_vip: true, from_branch_id: from_branch_id || self.user.try(:from_branch_id))
        count = self.class.applying.where(shop_id: self.shop_id).count
        self.shop.update_columns(applying_vip_info_count: count)
        if self.shop.vip_info_setting.auto_agree_applying
          agree_apply_vip
        else
          Ddt::Notification::Event::User::ApplyVip.create_and_send_notification(shop: self.shop, user: self.base_user)
        end
     end
    end

    def agree_apply_vip
      if is_apply_vip?
        vip_level = self.shop.vip_levels.where(is_default: false).order(level: :asc).first
        if vip_level.present?
          self.update(is_apply_vip: false, vip_level: vip_level, become_vip_at: Time.now)
          self.base_users.each(&:touch)
          self.shop.decrement!(:applying_vip_info_count)
          Ddt::Promotion::Events::UserActiveVip.create!(user: self.base_user)
        else
          self.errors[:base] << "请先设置会员级别"
          false
        end
      end
    end

    def block(bool=true)
      user.update(is_blocked: bool) if user.present?
    end

    def reject_apply_vip
      if is_apply_vip?
        self.update(is_apply_vip: false)
        self.shop.decrement!(:applying_vip_info_count)
        self.base_users.each(&:touch)
      end
    end

    def self.merge_info(source_vip, target_vip)
      Ddt::VipInfo.transaction do
        if source_vip.can_merge_to(target_vip)
          [:phone, :name, :sex, :id_number, :birthday, :address, :email, :note].each do |column|
            if target_vip.send(column).blank? && source_vip.send(column).present?
              target_vip.send("#{column}=", source_vip.send(column))
            end
          end
          source_vip.orders.includes_none.each{|o| o.vip_info_id = target_vip.id; o.save}
          target_vip.total_amount = target_vip.total_amount + source_vip.total_amount
          target_vip.placed_orders_count += source_vip.placed_orders_count
          if source_vip.vip_level.discount < target_vip.vip_level.discount
            target_vip.vip_level = source_vip.vip_level
          end
          target_vip.save!
          target_vip.card_wallet.merge(source_vip.card_wallet)
          target_vip.credits_wallet.merge(source_vip.credits_wallet)
          source_vip.base_users.update_all(vip_info_id: target_vip.id, original_vip_info_id: source_vip.id)
          self.reset_counters(target_vip.id, :base_users)
          self.reset_counters(source_vip.id, :base_users)
          source_vip.destroy
        else
          raise source_vip.errors.full_messages
        end
      end
    end

    def can_merge_to(target_vip)
      if target_vip.builtin?
        self.errors.add(:base, "要绑定的目标会员信息不能为默认会员信息")
        false
      elsif !self.builtin?
        self.errors.add(:base, "当前用户已经绑定过会员信息，不允许绑定其他会员信息")
        false
      else
        true
      end
    end

    def get_scan_code
      if self.scan_code.present? && self.updated_scan_code_at.present? && self.updated_scan_code_at > 2.minutes.ago
        self.scan_code
      else
        code = "#{self.id}#{Random.rand(899999)+100000}"
        self.scan_code = code.length % 2 == 0 ? code : "0#{code}"
        self.scan_code = "19" + self.scan_code
        self.update_columns(scan_code: self.scan_code, updated_scan_code_at: Time.now)
        self.scan_code
      end
    end

    def scan_code_html
      {
        qrcode: RQRCode::QRCode.new(self.get_scan_code, :size => 4, :level => :l ).as_html, # 二维码
        barcode: Barby::Code128C.new(self.get_scan_code).to_html  # 条形码
      }
    end

    def self.get_by_scan_code(scan_code)
      id = scan_code[2...-6]
      vip_info = self.find_by(id: id)
      if vip_info.present? && vip_info.scan_code == scan_code && vip_info.updated_scan_code_at > 2.minutes.ago
        vip_info
      else
        nil
      end
    end

    concerning :InfoMethod do
      included do
        # columns
        # :name, :phone, :vip_level_id, :vip_no, :sex, :id_number, :birthday, :address, :email, :note, :total_amount, :last_placed_at
        # :vip_level_name, :vip_level_discount, :vip_level_is_default,
        delegate :name, :discount, :is_default, to: :vip_level, prefix: true
        # :discount, :is_default
        delegate :discount, :is_default, to: :vip_level
        # :total_recharge_money
        delegate :total_recharge_money, to: :card_wallet
        # :card_wallet_amount
        delegate :amount, to: :card_wallet, prefix: true
        # :total_get_credits, :total_used_credits
        delegate :total_get_credits, :total_used_credits, to: :credits_wallet
        # :credits_wallet_amount
        delegate :amount, to: :credits_wallet, prefix: true
        # :user_nickname, :user_phone, :user_is_blocked
        delegate :nickname, :phone, :is_blocked, to: :user, prefix: true, allow_nil: true

        def is_wechat_user?
          self.user.present?
        end
        alias_method :is_wechat_user, :is_wechat_user?

        def user_id
          user.try(:id)
        end

        def user_placed_orders_count
          placed_orders_count
        end
      end
    end

    def available_card_wallet_amount
      if first_recharge_at.present? && first_recharge_at.to_date == Date.today
        self.card_wallet.amount - self.first_recharge_limited_amount
      else
        self.card_wallet.amount
      end
    end

    def order_complete(order)
      add_total_amount(order.total) unless order.is_recharge?
      self.user.clear_continuous_cancel_order_count if self.user.present?
    end

    def add_total_amount(amount)
      ::Ddt::VipInfo.where(id: self.id).update_all("total_amount = total_amount + #{amount}")
      check_auto_upgrade
    end

    def can_destroy?
      self.user.blank?
    end

    private
    def create_wallets
      self.build_card_wallet
      self.build_credits_wallet
    end

    def create_default_password
      if self.pay_password_hash.blank?
        self.pay_password_hash = Password.create(self.shop.vip_info_setting.default_password, :cost => 5)
      end
    end

    def fill_base_users_msg
      if self.phone_changed?
        self.base_users.where("phone is null or phone = ''").update_all(phone: self.phone)
      end
    end
  end
end
