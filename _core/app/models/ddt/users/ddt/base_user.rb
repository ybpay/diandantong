module Ddt
  class BaseUser < Ddt::Base
    include Discard::Model
    default_scope { kept }

    acts_as_type :type, ['Ddt::User', 'Ddt::PhoneUser', 'Ddt::WebUser', 'Ddt::WifiUser'], %W[微信用户 电话用户 网站用户 wifi用户]
    ##### relationship
    include Ddt::BelongsToShop
    include LatLng

    attr_accessor :name

    has_many :coupons_of_applied, class_name: 'Ddt::BaseCoupon', as: :operator
    belongs_to :unique_user, class_name: 'Ddt::UniqueUser' #便于搜索，将本应属于user的关系移到此处BaseUser
    belongs_to :vip_info, class_name: 'Ddt::VipInfo', counter_cache: true
    delegate :get_price_of_itemable, :available_card_wallet_amount, to: :vip_info

    has_many_orders :orders
    has_many_orders :active_orders,      ->{ active }
    has_many_orders :delivery_orders,    ->{ delivery }
    has_many_orders :reservation_orders, ->{ reservation }
    has_many_orders :eat_in_hall_orders, ->{ eat_in_hall }
    has_many_orders :fastfood_orders,    ->{ fastfood }
    has_many_orders :groupon_orders,     ->{ groupon }
    has_many_orders :recharge_orders,    ->{ recharge }
    has_many_orders :payment_orders,     ->{ payment }

    has_many :promotion_events, class_name: 'Ddt::PromotionEvent'
    has_many :addresses, class_name: 'Ddt::Address'
    has_many :user_branch_favoriteships, class_name: 'Ddt::UserBranchFavoriteship'
    has_many :favorite_branches, through: :user_branch_favoriteships, class_name: 'Ddt::Branch'
    has_many :sign_records, class_name: 'Ddt::SignRecord'
    has_many :base_coupons, class_name: 'Ddt::BaseCoupon'
    has_many :coupons,  class_name: 'Ddt::Coupon'
    has_many :groupons, class_name: 'Ddt::Groupon'
    has_many :vouchers, class_name: 'Ddt::Voucher'
    has_many :sharable_coupons, class_name: 'Ddt::SharableCoupon'
    has_many :short_messages, class_name: 'Ddt::ShortMessage', as: :owner

    has_many :guest_queues, class_name: 'Ddt::GuestQueue'
    has_many :coupons, class_name: 'Ddt::Coupon'
    delegate :card_wallet, :credits_wallet, :last_placed_at, to: :vip_info
    has_many :order_itemables, class_name: "Ddt::OrderItemable"

    #####validations
    valid_phone :phone
    validates :type, presence: true

    #####callback
    after_create :increment_users_counts
    before_save :create_default_vip_info
    before_destroy :destroy_favorite_branches

    ### scopes
    scope :of_normal_users, -> do
      joins(vip_info: :vip_level).where("ddt_vip_levels.is_default = true")
    end

    scope :of_vip_users, -> do
      joins(vip_info: :vip_level).where("ddt_vip_levels.is_default = false")
    end

    scope :user, -> { where(type: 'Ddt::User')}
    scope :phone_user, -> { where(type: 'Ddt::PhoneUser')}
    scope :web_user, -> { where(type: 'Ddt::WebUser')}
    scope :wifi_user, -> { where(type: 'Ddt::WifiUser')}


    def default_address
      self.addresses.default.first
    end

    def self.current= (user)
      RequestStore.store[:current_user] = user
    end

    def self.current
      RequestStore.store[:current_user]
    end

    def select_json
      { id: self.id, name: self.to_label}
    end

    def as_api_json
      {
        id: id,
        name: to_label,
        phone: phone,
        email: email,
        type: type,
        type_name: type_name,
        shop_id: shop_id,
        vip_info_id: vip_info_id,
        orders_count: orders_count,
        total_amount: total_amount,
        is_blocked: is_blocked?,
        last_latitude: last_latitude,
        last_longitude: last_longitude,
        last_location_label: last_location_label,
        last_location_time: last_location_time,
        created_at: created_at,
        updated_at: updated_at,
        vip_info: vip_info&.as_api_json
      }
    end

    def to_label
      [self.name, self.phone, self.email, self.id].compact.join(" - ")
    end

    def cart_of_branch(branch, type='delivery')
      cart = self.send("#{type}_carts").where(branch: branch).first
      cart = self.send("#{type}_carts").create(branch: branch) if cart.blank?
      cart
    end

    def sign
      self.sign_records.create unless today_signed?
    end

    def today_signed?
      self.sign_records.today.present?
    end

    def sign_history
      history = []
      records = self.sign_records.where("created_at BETWEEN '#{6.days.ago.beginning_of_day}' AND '#{Time.now.end_of_day}'").to_a
      ((6.days.ago.to_i)...1.minute.from_now.to_i).step(1.day.to_i) do |time_i|
        time = Time.at(time_i)
        history << {
          label:  time.strftime('%-m月%-d日'),
          signed: records.any?{|r| r.created_at > time.beginning_of_day && r.created_at < time.end_of_day }
        }
      end
      history
    end

    def vip_discount
      self.vip_info.discount
    end

    # 连续取消订单次数限制，超过此值会在后台订单管理页面提醒门店。
    CONTINUOUS_CANCEL_LIMIT = 5

    def increase_continuous_cancel_order_count
      self.increment!(:canceled_order_count, 1)
      self.increment!(:continuous_cancel_order_count, 1)
    end

    def clear_continuous_cancel_order_count
      self.update!(continuous_cancel_order_count: 0)
    end

    # 是否是会员
    def vip?
      !normal?
    end

    def normal?
      self.vip_info.vip_level.is_default
    end

    private
    def increment_users_counts
      if self.shop.present?
        Shop.increment_counter "base_users_count", shop_id
        Shop.increment_counter "#{self.type.demodulize.pluralize.underscore}_count", shop_id if self.type.present?
      end
    end

    def destroy_favorite_branches
      self.favorite_branches.clear
    end

    def create_default_vip_info
      if self.shop.present?
        vip_level = self.shop.default_vip_level
        if self.vip_info_id.blank?
          vip_no    = Ddt::VipInfo.random_vip_no(self.shop)
          self.vip_info  = self.shop.vip_infos.create!(
            vip_level: vip_level,
            vip_no: vip_no,
            name: self.name,
            # phone: self.phone,
            builtin: true
            )
        end
      end
    end
  end
end
