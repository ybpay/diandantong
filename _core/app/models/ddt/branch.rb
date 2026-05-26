#encoding: utf-8
module Ddt
  class Branch < Ddt::Base
    include Ddt::ActsAsCacheVersionScope

    # 迁移、修复数据用， 每多少订单换一天
    ORDERS_PER_DAY = 10

    is_impressionable
    filter_unicode_for :name, :introduction
    ### relationships
    include Ddt::Commentable
    include Ddt::HasManyTags
    include ListScope
    include LatLng

    acts_as_mappable :default_units => :kms,
                   :default_formula => :flat,
                   :distance_field_name => :distance,
                   :lat_column_name => :latitude,
                   :lng_column_name => :longitude

    include Ddt::SoftDeletable

    acts_as_type :product_list_style, [:thumb, :txt], %W[缩略图风格 文本风格]
    acts_as_type :moling_type, [:moling_erase, :moling_round], %W[直接抹除 四舍五入]
    acts_as_type :moling_precision, [:moling_shi, :moling_yuan, :moling_jiao, :moling_fen], %W[十 元 角 分]
    acts_as_list scope: [:shop_id, :is_abstract]
    acts_as_cache_version_scope_of :category, :product, :combo, :table_zone
    acts_as_type :branch_category, [:hotpot, :chinese, :japanese, :western, :fastfood, :others], %W[火锅 中餐 日料 西餐 快餐 其他]

    belongs_to :shop, class_name: 'Ddt::Shop'
    belongs_to :branch_type, counter_cache: true, class_name: 'Ddt::BranchType'
    has_and_belongs_to_many :branch_groups, :join_table => 'ddt_branches_branch_groups', :class_name => 'Ddt::BranchGroup', :after_add => :touch_branch_group, :after_remove => :touch_branch_group
    has_one :delivery_setting, class_name: 'Ddt::DeliverySetting'
    has_one :branch_ext, class_name: 'Ddt::BranchExt'
    delegate :min_delivery_fee, :support_delivery_if_amount_gt,
             :receive_delivery_order_within_days, :use_fixed_delivery_time, :delivery_radius,
             :delivery_need_minutes, :support_order_if_not_in_delivery_radius, :delivery_dates, :is_charge_by_distance,
             :default_shipment, to: :delivery_setting
    has_one :eat_in_hall_setting, class_name: 'Ddt::EatInHallSetting'
    delegate :auto_clear_table, :disable_service, to: :eat_in_hall_setting
    has_one :reservation_setting, class_name: 'Ddt::ReservationSetting'
    delegate :average_consumption, to: :reservation_setting
    has_one :credits_wallet, as: :owner, class_name: 'Ddt::BranchCreditsWallet'
    has_one :card_wallet, as: :owner, class_name: 'Ddt::BranchCardWallet'
    has_one :last_import_product_error, class_name: 'Ddt::LastImportProductError'

    has_many :comments, class_name: 'Ddt::Comment', foreign_key: :branch_id
    has_many :branch_comments, -> {where(commentable_type: 'Ddt::Order')}, class_name: 'Ddt::Comment', foreign_key: :branch_id
    has_many :user_branch_favoriteships, class_name: "Ddt::UserBranchFavoriteship"
    has_many :followed_users, class_name: 'Ddt::BaseUser', through: :user_branch_favoriteships
    has_many :service_periods, class_name: 'Ddt::ServicePeriod', inverse_of: :branch
    accepts_nested_attributes_for :service_periods, :allow_destroy => true
    has_many :table_zones, class_name: 'Ddt::TableZone'
    has_many :tables, class_name: 'Ddt::Table'
    has_many :reservation_time_points, class_name: 'Ddt::ReservationTimePoint'
    has_many :reservation_infos, class_name: 'Ddt::ReservationInfo'
    has_many :manageships, class_name: 'Ddt::Manageship', dependent: :destroy
    has_many :managers, through: :manageships, source: :account
    has_many :targets_customs, class_name: 'Ddt::TargetsCustom'
    has_many :targets, class_name: 'Ddt::Target'
    has_many :waiter_service_items, class_name: 'Ddt::WaiterServiceItem'
    has_one :print_setting, class_name: 'Ddt::PrintSetting'
    has_one :arranging_setting, class_name: 'Ddt::ArrangingSetting'
    has_many :competition_resources, class_name: 'Ddt::CompetitionResource', as: :owner
    has_many :shipments, class_name: 'Ddt::Shipment'
    has_one :bill_template_setting
    has_one :kitchen_setting
    has_many :tick_accounts

    # for directly access underlay attribute
    include Ddt::CarrierWaveBridge
    mount_uploader :image, BranchImageUploader
    mount_uploader :rect_image, BranchRectImageUploader
    has_many :products, class_name: 'Ddt::Product'
    has_many :variants, class_name: 'Ddt::Variant'
    has_many :option_types, class_name: 'Ddt::OptionType'
    has_many :categories, class_name: 'Ddt::Category'
    has_many :root_categories, -> {root}, class_name: 'Ddt::Category'
    has_many :combos, class_name: 'Ddt::Combo'
    has_many :combo_items, class_name: 'Ddt::ComboItem'
    has_many :combo_packages, class_name: 'Ddt::ComboPackage'
    has_many :variant_packages, class_name: 'Ddt::VariantPackage'
    has_many :guest_queues, class_name: 'Ddt::GuestQueue'
    has_many :queue_settings, class_name: 'Ddt::QueueSetting'
    has_and_belongs_to_many :zones, class_name: 'Ddt::Zone', :join_table => 'ddt_branches_zones'
    has_and_belongs_to_many :coupon_versions, ->{where(:type => [Ddt::CouponVersion])}, join_table: 'ddt_abstract_coupon_versions_branches', class_name: 'Ddt::CouponVersion'
    has_many :abstract_coupon_versions, class_name: 'Ddt::AbstractCouponVersion'
    has_and_belongs_to_many :groupon_versions, class_name: 'Ddt::GrouponVersion', join_table: 'ddt_abstract_coupon_versions_branches'
    has_and_belongs_to_many :voucher_versions, class_name: 'Ddt::GrouponVersion', join_table: 'ddt_abstract_coupon_versions_branches'
    has_and_belongs_to_many :tuans, ->{where(:type => [Ddt::GrouponVersion, Ddt::VoucherVersion])}, class_name: 'Ddt::AbstractCouponVersion', join_table: 'ddt_abstract_coupon_versions_branches'
    has_many :delivery_zones, class_name: 'Ddt::DeliveryZone'
    has_many :delivery_times, :through => :delivery_setting
    has_many :delivery_ranges, class_name: 'Ddt::DeliveryRange'
    has_many :discount_plans, class_name: 'Ddt::DiscountPlan'

    has_many_orders :orders
    has_many_orders :delivery_orders,    ->{ delivery }
    has_many_orders :reservation_orders, ->{ reservation }
    has_many_orders :eat_in_hall_orders, ->{ eat_in_hall }
    has_many_orders :fastfood_orders,    ->{ fastfood }
    has_many_orders :groupon_orders,     ->{ groupon }
    has_many_orders :recharge_orders,    ->{ recharge }
    has_many_orders :payment_orders,     ->{ payment }

    def litps
      OrderService::Litps.where(branch_id: self.id)
    end

    has_many :payments, class_name: 'Ddt::Payment'
    has_many :promotions, class_name: 'Ddt::Promotion'
    has_many :event_promotions, class_name: 'Ddt::EventPromotion'
    has_many :order_promotions, class_name: 'Ddt::OrderPromotion'
    has_many :product_promotions, class_name: 'Ddt::ProductPromotion'
    has_many :promotion_rules, class_name: 'Ddt::PromotionRule'
    has_many :promotion_actions, class_name: 'Ddt::PromotionAction'
    has_and_belongs_to_many :shop_event_promotions, class_name: 'Ddt::EventPromotion', join_table: 'ddt_promotions_branches'
    has_and_belongs_to_many :shop_order_promotions, class_name: 'Ddt::OrderPromotion', join_table: 'ddt_promotions_branches'
    has_many :top_sales, -> {limit(4)} , class_name: 'Ddt::Variant' # FIXME: 将来想办法换成真正的 TOP SALES
    has_many :printers, class_name: 'Ddt::Printer'
    ids_string_for :zones
    has_many :form_elements, -> { where("form_element_id is null or form_element_id = 0").order('sequence ASC') }, class_name: 'Ddt::FormElement'
    has_many :all_tags, -> {order(count: :desc)}, class_name: 'Ddt::Tag'
    has_many :item_notes, class_name: 'Ddt::ItemNote'
    has_many :item_note_tags, class_name: 'Ddt::ItemNoteTag'
    has_many :product_tags, class_name: 'Ddt::ProductTag'
    has_many :exchange_codes, class_name: 'Ddt::ExchangeCode'
    has_one :delivery_pay_method_setting, class_name: 'Ddt::PayMethodSetting::Delivery'
    has_one :eat_in_hall_pay_method_setting, class_name: 'Ddt::PayMethodSetting::EatInHall'
    has_one :fastfood_pay_method_setting, class_name: 'Ddt::PayMethodSetting::Fastfood'
    has_one :groupon_pay_method_setting, class_name: 'Ddt::PayMethodSetting::Groupon'
    has_one :reservation_pay_method_setting, class_name: 'Ddt::PayMethodSetting::Reservation'
    has_one :payment_pay_method_setting, class_name: 'Ddt::PayMethodSetting::Payment'
    delegate :recharge_pay_method_setting, to: :shop
    has_many :pay_method_settings, class_name: 'Ddt::PayMethodSetting'
    accepts_nested_attributes_for :delivery_pay_method_setting, update_only: true
    accepts_nested_attributes_for :eat_in_hall_pay_method_setting, update_only: true
    accepts_nested_attributes_for :fastfood_pay_method_setting, update_only: true
    accepts_nested_attributes_for :groupon_pay_method_setting, update_only: true
    accepts_nested_attributes_for :reservation_pay_method_setting, update_only: true
    accepts_nested_attributes_for :payment_pay_method_setting, update_only: true
    accepts_nested_attributes_for :eat_in_hall_setting, update_only: true
    has_many :shifts, class_name: "Ddt::Shift"
    has_many :essential_products, class_name: 'Ddt::EssentialProduct'
    has_one :cs_branch_binding, class_name: 'Ddt::CsBranchBinding'
    has_one :sale_data_uploader_setting

    scope :open_on_monday,      ->(is_open=true){ where(open_on_monday: is_open)}
    scope :open_on_tuesday,     ->(is_open=true){ where(open_on_tuesday: is_open)}
    scope :open_on_wednesday,   ->(is_open=true){ where(open_on_wednesday: is_open)}
    scope :open_on_thursday,    ->(is_open=true){ where(open_on_thursday: is_open)}
    scope :open_on_friday,      ->(is_open=true){ where(open_on_friday: is_open)}
    scope :open_on_saturday,    ->(is_open=true){ where(open_on_saturday: is_open)}
    scope :open_on_sunday,      ->(is_open=true){ where(open_on_sunday: is_open)}
    scope :open_on_wday, ->(wday){
      case wday
      when 0; open_on_sunday;
      when 1; open_on_monday;
      when 2; open_on_tuesday;
      when 3; open_on_wednesday;
      when 4; open_on_thursday;
      when 5; open_on_friday;
      when 6; open_on_saturday;
      end
    }
    scope :open_on_date,        ->(date_str){
      if date_str.present?
        if date_str.is_a? Date
          date = date_str
        elsif date_str.is_a? String
          date = Date.parse(date_str)
        end
      else
        date = Date.today
      end
      if date == Date.today
        open_on_now
      else
        open_on_wday(date.wday)
      end
    }
    scope :open_on_today,        ->{ open_on_wday(Time.now.wday) }
    def is_open_on_today?
      case Time.now.wday
      when 0; open_on_sunday?;
      when 1; open_on_monday?;
      when 2; open_on_tuesday?;
      when 3; open_on_wednesday?;
      when 4; open_on_thursday?;
      when 5; open_on_friday?;
      when 6; open_on_saturday?;
      end
    end

    # [:delivery, :eat_in_hall, :fastfood, :groupon, :reservation, :payment].each do |it|
    #   alias_method "direct_#{it}_pay_method_setting".to_sym, "#{it}_pay_method_setting".to_sym
    #   define_method "#{it}_pay_method_setting".to_sym do
    #     if TCC.enable?
    #       TCC.fetch("branch.#{self.id}.#{it}_pay_method_setting") do
    #         self.pay_method_settings.each do |pay_method_setting|
    #           TCC.write("branch.#{self.id}.#{pay_method_setting.type.demodulize.underscore}_pay_method_setting", pay_method_setting)
    #         end
    #         TCC.fetch("branch.#{self.id}.#{it}_pay_method_setting"){nil}
    #       end
    #     else
    #       self.send("direct_#{it}_pay_method_setting".to_sym)
    #     end
    #   end
    # end

    scope :in_zone, ->(zone_id){
      zone = Zone.find(zone_id)
      incZones = Zone.of_ancestor(zone)
      joins(:zones).where(:ddt_zones => { id:incZones.map(&:id)})
    }

    scope :valid_now, -> {
      where("expiration_time > :now", now: Time.now.to_date)
    }


    # 正在营业的门店
    # unused参数是为了使ransack正常工作添加的。
    scope :of_in_service, ->(unused = nil) do
      clauses = [
        "(start_at < end_at AND start_at <= :t AND end_at > :t)",
        "(start_at > end_at AND start_at <= :t OR end_at > :t)"
      ]
      joins(:service_periods).where(clauses.join(" OR "), t: Time.now)
    end

    scope :branch_tag_id_eq, ->(branch_tag_id) do
      joins(:tags).where('ddt_tags.id = :tag_id', tag_id: branch_tag_id)
    end

    scope :real, -> { where(is_abstract: false) }
    scope :abstract, -> { where(is_abstract: true) }
    scope :with_abstract, -> { unscope(where: :is_abstract)}

    ### validations
    with_options unless: :is_abstract? do |klass|
      klass.validates :phone, length: 3..20, allow_blank: true
      klass.validates :latitude, presence: true, :numericality => {:greater_than => -90, :less_than => 90}
      klass.validates :longitude, presence: true, :numericality => {:greater_than => -180, :less_than => 180}
      klass.validates :name, :address, :product_list_style, :branch_category, presence: true
      klass.validates :image      , file_size: { maximum: 0.5.megabytes.to_i }
      klass.validates :rect_image , file_size: { maximum: 0.5.megabytes.to_i }
      klass.validates_associated :service_periods
      klass.validate :validate_max_branches_limit, on: :create
      klass.validates :branch_type, :parking_space_count, presence: true
      klass.validates :hasten_minute_since_place, presence: true, :numericality => {integer: true, greater_than: -1}
      klass.validates :table_sticker_custom_line1, length: {maximum: 10}
      klass.validates :table_sticker_custom_line2, length: {maximum: 10}

    end

    ### callbacks
    after_create do
      self.create_delivery_setting!
      self.create_reservation_setting!
      self.create_eat_in_hall_setting!
      self.create_print_setting!
      self.create_arranging_setting!
      self.competition_resources.create!(name: :order_number)
      self.create_bill_template_setting!
      self.create_sale_data_uploader_setting!
      self.create_kitchen_setting!
    end
    after_create :create_wallets
    after_create :create_pay_method_settings
    # before_destroy :decrement_branch_type_count
    # after_create :increment_branch_type_count
    after_create  :update_shop_branches_count
    after_destroy :update_shop_branches_count
    after_save :update_branch_type_branches_count

    def self.change_orders_count_to_time(orders_count)
      n = orders_count / ORDERS_PER_DAY + (orders_count % ORDERS_PER_DAY == 0 ? 0 : 1)
      n = n > 3650 ? 3650 : n
      Time.now + n.days
    end

    def deliverymans
      managers.deliverymans
    end

    def open_days
      [:open_on_monday, :open_on_tuesday, :open_on_wednesday, :open_on_thursday,
        :open_on_friday, :open_on_saturday, :open_on_sunday].
        select{|method| self.send(method.to_sym)}.map{|method| Ddt::Branch.human_attribute_name(method.to_sym)}.join(", ")
    end

    def commentable_label
      "评论给： " + name
    end

    def select_json
      { id: self.id, name: self.name, text: self.name }
    end

    def queue_states_json
      self.queue_settings.map do |q|
        {
          id: q.id,
          count: q.guest_queues.with_queueing_state.count,
          head: q.current_queue_head.try(:guest_no),
          front: q.current_queue_head.try(:front_guest_no)
        }
      end
    end

    def is_followed_by(base_user)
        # self.followed_users.where(base_user_id: base_user.id).any?
        self.followed_users.include? base_user
    end

    def is_in_service
      if is_open_on_today?
        time = DateTime.now
        self.service_periods.select{|service_period| service_period.is_in_service_time?(time)}.any? rescue false
      else
        false
      end
    end

    def is_open_name
        is_open_on_today? ? I18n.t('branch.is_open.opened') : I18n.t('branch.is_open.closed')
    end

    def distance_of(user)
      if user.present? && self.lat_lng_present? && user.lat_lng_present?
          distance = Geocoder::Calculations.distance_between(self.lat_lng, user.lat_lng) * 1.609344 * 1000
          distance.to_i
      else
        nil
      end
    end

    # 已成交订单数
    def finish_order_count
      orders.completed.count
    end

    # 平均评分
    def average_rate
      rating
    end

    # 与订单相关的工作人员
    # 包括店长、有订单查看和操作权限的自定义角色人员
    # 不包括厨师！
    def order_related_people
      manager_ids = self.managers.pluck(:id)
      if manager_ids.present?
        roles = Ddt::Role.joins("INNER JOIN ddt_accounts_roles ON ddt_roles.id = ddt_accounts_roles.role_id").where("ddt_accounts_roles.account_id IN (?)", manager_ids)
      else
        roles = []
      end

      self.managers.select do |person|
        my_roles = roles.select{|it| it.account_id = person.id}
        builtin_role_result = my_roles.select{|it| %W[Ddt::Role::Worker Ddt::Role::Cashier Ddt::Role::Waiter].include?(it.type)}.present?
        if builtin_role_result
          true
        else
          permissions = my_roles.map(&:permissions).flatten.uniq
          custom_role_result = [:view_order, :operate_order].map do |permission|
            permissions.include?(permission)
          end.inject { |acc, elem| acc || elem }

          custom_role_result
        end
      end.push(self.shop.boss).flatten.uniq
    end

    def introduction_decoder
      ::HTMLEntities.new.decode(ActionView::Base.full_sanitizer.sanitize(self.introduction))
    end

    def all_pay_methods
      common = [:credits_deduction, :card_deduction, :alipay, :wechatpay, :baidupay, :vip_card_pay, :bank_card_pay]
      hash = {
        delivery:    common + [:pay_on_receive],
        eat_in_hall: common + [:pay_on_face],
        fastfood:    common + [:pay_on_face],
        reservation: common + [:pay_on_arrive],
        groupon:     common + [],
        recharge:    common + [],
        payment:     common + []
      }
      # 开启了预付款模式的扫码堂点
      if self.eat_in_hall_setting.is_pay_before?
        hash.merge!(eat_in_hall: common)
      end
      hash.inject({}) do |result, (order_type, pay_methods)|
        result[order_type] = {}
        pay_methods.each do |pay_method|
          result[order_type][pay_method] = self.pay_method_can?(order_type, pay_method)
        end
        result
      end
    end

    def pay_method_can?(order_type, pay_method)
      self.shop.pay_method_can?(order_type, pay_method) &&
      self.send("#{order_type}_pay_method_setting").send("can_#{pay_method}?")
    end

    def current_shift
      self.shifts.opening.first
    end

    def last_shift
      self.shifts.closed.last
    end

    def open_shift(account, pre_cash_amount)
      pre_cash_amount ||= 0
      self.errors[:base] << '当前门店已有人开班' if self.shifts.opening.present?
      if self.errors.empty?
        self.shifts.create!(account: account, pre_cash_amount: pre_cash_amount)
        self.touch
      end
    end

    def close_shift
      # self.errors[:base] << '尚有订单未未处理' if self.orders.active.count > 0
      self.errors[:base] << '未开班' unless self.current_shift.present?
      if self.errors.empty?
        self.current_shift.close
        self.touch
        true
      else
        false
      end
    end

    def touch_branch_group(branch_group = nil)
      branch_group.try(:touch)
    end

    def branches_in_group(options = {})
      default_options = {group_ids: [], include_self: false, same_group: true}
      default_options.merge! options
      q = self.shop.branches
              .includes(:branch_groups)
              .references(:ddt_branch_groups)
      q = q.where(ddt_branch_groups:{id: self.branch_group_ids}) if options[:same_group].present?
      q = q.where(ddt_branch_groups:{id: options[:group_ids]}) if options[:group_ids].present?
      q = q.where("ddt_branches.id != #{self.id}") if !options[:include_self]
      q
    end

    def webpos_printer_configed?
      self.printers.use_in_webpos.active.count > 0
    end

    def is_auto_complete_delivery_order?
      self.delivery_setting.enable_auto_complete?
    end

    def is_distance_limited?(order)
      ((self.distance_to(order.try(:user).try(:lat_lng), units: :kms) * 1000 > 500) rescue true)
    end

    private

    def create_wallets
      self.create_card_wallet!
      self.create_credits_wallet!
    end

    def create_pay_method_settings
      self.create_delivery_pay_method_setting!
      self.create_eat_in_hall_pay_method_setting!
      self.create_fastfood_pay_method_setting!
      self.create_groupon_pay_method_setting!
      self.create_reservation_pay_method_setting!
      self.create_payment_pay_method_setting!
    end

    def self.ransackable_scopes(auth_object = nil)
      %w(in_zone of_in_service branch_tag_id_eq)
    end

    def validate_max_branches_limit
      return unless self.shop
      if self.shop.branches(:reload).count >= self.shop.max_branches_limit
          errors.add(:base, :exceed_limit)
      end
    end

    def update_shop_branches_count
      self.shop.update(branches_count: self.shop.branches.count)
    end

    def update_branch_type_branches_count
      if self.branch_type_id_changed?
        if self.branch_type_id_was.present?
          Ddt::BranchType.reset_counters(self.branch_type_id_was, :branches)
        end
        Ddt::BranchType.reset_counters(self.branch_type_id, :branches)
      end
    end

  end
end
