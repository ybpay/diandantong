module Ddt
  class User < Ddt::BaseUser
    acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :last_latitude,
                   :lng_column_name => :last_longitude
    ### relationship
    include Ddt::CommentOwner
    has_many :wechat_users, dependent: :destroy, class_name: 'Ddt::WechatUser'
    has_many :wechat_share_records, class_name: 'Ddt::WechatShareRecord'
    has_many :wechat_view_records, class_name: 'Ddt::WechatViewRecord'
    has_many :viewed_wechat_share_records, through: :wechat_view_records, class_name: "Ddt::WechatShareRecord"
    delegate :headimgurl, :nickname, :sex, :sex_name, to: :unique_user
    has_many :accounts, class_name: 'Ddt::Account'
    has_one :merchant_apply
    has_many :invitation_order_guests, class_name: 'Ddt::InvitationOrderGuest', foreign_key: :guest_id
    has_many :invitation_orders, through: :invitation_order_guests, source: :order

    ### validations
    validates :unique_user, presence: true
    validates :last_latitude, :last_longitude, presence: true, on: :update

    delegate :user_open_id, to: :unique_user, allow_nil: true

    ### callback

    before_validation do
      self.last_location_time = DateTime.now if self.last_latitude_changed? or self.last_longitude_changed?
    end

    def self.find_or_create_shop_user(shop_id, gonghao_open_id, user_open_id)
      # 实际上从 unique_users 中，用 UOID 查找用户
      user = Ddt::User.includes(:unique_user).
              where(shop_id: shop_id, ddt_unique_users: {:gonghao_open_id=> gonghao_open_id, :user_open_id=>user_open_id})
              .references(:ddt_unique_users).first_or_initialize
      # 用户刷新所致？多进程同时访问，此进程无法观察到其它进程更新。
      if user.new_record?
        # user_open_id_index 记录重复，说明使用过其它 gonghao_open_id 来插入相同的 user_open_id
        unique_user = Ddt::UniqueUser.where(:gonghao_open_id=>gonghao_open_id, :user_open_id => user_open_id).first_or_create!
        user.unique_user = unique_user
        begin
          user.save(validate: false)
        rescue ActiveRecord::RecordNotUnique => e
          # 发现数据库里有重复的记录，重取之，以使流程继续进行下去
          Rails.logger.warn("duplicate unique_user record: shop_id: #{shop_id}, gonghao_open_id: #{gonghao_open_id}, user_open_id: #{user_open_id}")
          user = Ddt::User.includes(:unique_user).where(shop_id: shop_id, ddt_unique_users: {:gonghao_open_id=> gonghao_open_id, :user_open_id=>user_open_id}).references(:ddt_unique_users).first
        end
      end
      user
    end

    def self.system_wechat_account_user(user)
      wechat_account = Ddt::WechatAccount.system_wechat_account
      user_of_wechat_account(user, wechat_account)
    end

    def self.shop_wechat_account_user(user)
        wechat_account = user.shop.primary_wechat_account
        system_wechat_account_user = user_of_wechat_account(user, wechat_account)
    end

    def self.user_of_wechat_account(user, wechat_account)
      if wechat_account.present?
        tmp_user = (wechat_account.shop.users.find_by(unique_user_id: user.unique_user_id) rescue nil)
        unless tmp_user.present? and tmp_user.wechat_users.where(:gonghao_open_id => wechat_account.gonghao_open_id).blank?
          return tmp_user
        end
      end
      nil
    end

    def select_json
      { id: self.id, name: to_label }
    end

    def to_label
      [self.nickname, self.phone, self.email, self.id].select(&:present?).join(" - ")
    end

    def comment_owner_label
      self.nickname  || '匿名'
    end

    def primary_wechat_user
      primary_wechat_account = self.shop.primary_wechat_account
      self.wechat_users.where(gonghao_open_id: primary_wechat_account.try(:gonghao_open_id)).first
    end

    def is_account_user?
      account_user.present?
    end

    def account_user
      tmp_system_wechat_account_user = nil
      if self.shop.is_custom_system_weixin_notification?
        tmp_system_wechat_account_user = Ddt::User.shop_wechat_account_user(self)
      else
        tmp_system_wechat_account_user = Ddt::User.system_wechat_account_user(self)
      end
      if tmp_system_wechat_account_user.present?
        tmp_system_wechat_account_user.accounts.of_shop_id(self.shop_id).first
      end
    end

    def weixin_profile_path
      "weixin/shops/#{self.shop_id}/my?_ng_path=/user/profile"
    end

    def lat_lng
      [last_latitude, last_longitude]
    end

    def lat_lng=(lat_and_lng=[])
      last_latitude, last_longitude = lat_and_lng
    end

    concerning :PreOrderItemable do
      def has_pre_order?(branch)
        self.order_itemables.for_pre_order.where(branch: branch).count > 0
      end

      def pre_order_guest_num(branch)
        first = pre_order_itemables(branch).limit(1).first
        if first.guest_queue_id.present?
          first.guest_queue.guest_num
        else
          0
        end
      end

      def move_pre_order_to_table(branch, table_id)
        self.order_itemables.for_pre_order.where(branch: branch).update_all(store_type: 'for_merge_order', table_id: table_id, updated_at: Time.now)
      end

      def set_pre_order_itemables(cart)
        self.order_itemables.for_pre_order.delete_all
        cart.line_items.each do |line_item|
          self.order_itemables.for_pre_order.create(
            branch: cart.branch,
            itemable: line_item.itemable,
            quantity: line_item.quantity,
            note: line_item.note
          )
        end
      end

      def pre_order_itemables(branch)
        self.order_itemables.for_pre_order.where(branch: branch)
      end

      def clear_pre_order_itemables(branch)
        self.order_itemables.for_pre_order.where(branch: branch).delete_all
      end

    end
  end
end
