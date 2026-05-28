module Ddt
  class Table < Ddt::Base
    include Discard::Model
    default_scope { kept }
    include BelongsToBranch
    include Ddt::Scanable
    include AASM
    acts_as_type :track_from, [:FromWechat, :FromWebpos, :FromWebstore, :FromApp, :FromUnknow, :FromWifi], %W[微信 收银端 网站 App 未知 Wifi堂点]
    ### relationships
    belongs_to :table_zone, :counter_cache => true, class_name: 'Ddt::TableZone'
    belongs_to_order name: :current_order
    has_many_orders :orders
    has_many :reservation_infos, class_name: 'Ddt::ReservationInfo'
    has_many :reservation_orders, through: :reservaiton_infos, source: :reservation_order
    has_and_belongs_to_many :printers, :join_table => 'ddt_printers_tables', class_name: 'Ddt::Printer'
    has_many :order_itemables
    attr_accessor :terminal_id, :operator

    delegate :weixin_ban_product_ids, :webpos_ban_product_ids, :ban_selfpay, :ban_selfpay?, to: :table_zone


    ### validations
    validates :name, presence: true
    validates :table_zone, presence: true
    validates :capacity, presence: true, numericality: {greater_than: 0}
    before_validation :set_default_guest_num

    set_from :table_zone

    default_scope ->{ order("table_zone_id asc, position asc")}
    touch_cache_version_of_scope :branch, "ddt/table_zones"

    acts_as_type :workflow_state, [:idle, :opened, :ordered, :check_outing, :paid], %W(空闲 已开台 已下单 结帐中 已支付)
    aasm column: :workflow_state, initial: :idle do
      state :idle, :opened, :ordered, :check_outing, :paid

      event :open do
        transitions from: [:idle, :opened], to: :opened
      end
      event :order do
        transitions from: [:idle, :opened], to: :ordered
      end
      event :clear do
        transitions from: [:opened, :paid], to: :idle
      end
      event :pay do
        transitions from: [:ordered, :check_outing], to: :paid
      end
      event :cancel do
        transitions from: :ordered, to: :idle
      end
      event :check_out do
        transitions from: :ordered, to: :check_outing
      end
      event :cancel_check_out do
        transitions from: :check_outing, to: :ordered
      end
      event :anti_settlement do
        transitions from: [:idle, :opened, :paid], to: :ordered
      end
      event :force_clear do
        transitions from: [:opened, :ordered, :check_outing, :paid], to: :idle
      end

      # open
      after_transition on: :open do |table, transition|
        num = transition.args.first
        table.update!(guest_num: num) if num.present?
        table.touch(:last_opened_at)
        Notification::Event::Table::Opened.create_and_send_notification(table_id: table.id, terminal_id: table.terminal_id)
        Ddt::OpenedTableClearWorker.perform_in(20.minutes, table.id)
      end

      # order
      after_transition on: :order do |table, transition|
        if transition.from_state == :idle
          table.touch(:last_opened_at)
        end
        order = transition.args.first
        table.update!(current_order: order, guest_num: order.guest_num, item_total: order.item_total, track_from: order.track_from)
      end

      # cancel
      after_transition on: :cancel do |table|
        table.update!(guest_num: 0, current_order: nil, item_total: 0, track_from: nil)
      end

      # clear
      after_transition on: :clear do |table|
        table.update!(guest_num: 0, current_order: nil, item_total: 0, track_from: nil)
        table.destroy_merge_itemables
        Notification::Event::Table::Cleared.create_and_send_notification(table_id: table.id, terminal_id: table.terminal_id)
      end

      # check_out
      after_transition on: :check_out do |table, transition|
        is_local_printed = transition.args.first.present? && transition.args.first>0
        Notification::Event::Table::CheckOut.create_and_send_notification(table_id: table.id, order_id: table.current_order_id, terminal_id: table.terminal_id, is_local_printed: is_local_printed, operator_id: table.operator.try(:id))
      end

      # cancel_check_out
      after_transition on: :cancel_check_out do |table|
        Notification::Event::Table::CancelCheckOut.create_and_send_notification(table_id: table.id, order_id: table.current_order_id, terminal_id: table.terminal_id)
      end

      # anti_settlement
      after_transition on: :anti_settlement do |table, transition|
        order = transition.args.first
        table.update!(current_order: order, guest_num: order.guest_num, item_total: order.item_total, track_from: order.track_from) if order
        table.send_anti_settlement_msg
      end

      # force_clear
      after_transition on: :force_clear do |table, transition|
        table.current_order.add_change_log(:force_clear) if table.current_order.present?
        table.current_order.save if table.current_order.present?
        table.update!(current_order_id: nil, guest_num: 0, item_total: table.current_order.try(:item_total), track_from: nil)
        table.destroy_merge_itemables
        Notification::Event::Table::Cleared.create_and_send_notification(table_id: table.id, terminal_id: table.terminal_id)
      end
    end

    def state
      workflow_state
    end

    def active?
      [:ordered, :paid, :check_outing].include?(workflow_state.to_sym)
    end

    def scan(user)
      if [:idle, :opened].include?(workflow_state.to_sym)
        if user.has_pre_order?(branch)
          clear
          guest_num = user.pre_order_guest_num(branch)
          open(guest_num) if guest_num != 0
          user.move_pre_order_to_table(branch, self.id)
        else
          clear if need_clear_merge_itemables?(user)
        end
      end
      # ordered, paid, check_outing states: no-op
    end

    def allow_scan?(user)
      true
    end

    def current_order?(order)
      self.current_order_id == order.id
    end

    def active_order
      self.orders.active.first
    end


    concerning :WebposMessage do
      def send_anti_settlement_msg
        all_managers.each do |account|
          WebposNotify.send_anti_settlement_msg(account.id, self, terminal_id)
        end
      end

      private
      def all_managers
        self.branch.order_related_people
      end
    end

    concerning :Path do
      # 当用户扫码后目标对象为该model时，系统自动跳转的路由地址
      def weixin_path
        case self.workflow_state.to_sym
        when :idle
          "/cart?_ng_path=/branches/#{self.branch_id}/tables/#{self.id}"
        when :opened
          "/cart?_ng_path=/branches/#{self.branch_id}/products/eat_in_hall"
        when :ordered, :check_outing, :paid
          "/order?_ng_path=/branches/#{self.branch_id}/orders/eat_in_hall/#{self.current_order_id}"
        end
      end
    end

    def can_reservation?(date, reservation_time_point)
      self.reservation_infos.where(reservation_date: date..date.next, reservation_time_point: reservation_time_point).blank?
    end

    def name_with_zone
      "#{table_zone.try(:name)}-#{name}"
    end

    def guest_num_label
      guest_num.blank? ? "" : " (#{guest_num}位)"
    end

    def select_json
      {id: self.id, name: self.name_with_zone}
    end

    concerning :TableCounterCache do
      included do
        before_save :fix_table_zone_tables_count, :if => ->(table) { !table.new_record? && table.table_zone_id_changed? }
      end
      private
      def fix_table_zone_tables_count
        TableZone.decrement_counter(:tables_count, self.table_zone_id_was)
        TableZone.increment_counter(:tables_count, self.table_zone_id)
      end
    end

    def update_guest_num(num)
      update(guest_num: num)
    end

    def set_default_guest_num
      update(guest_num: 0) if self.guest_num.nil?
    end

    def destroy_merge_itemables
      self.order_itemables.for_merge_order.delete_all
    end

    def need_clear_merge_itemables?(user)
      return false if self.guest_num.blank? || self.guest_num == 0 || !self.is_opened?
      return true if order_itemable_of_current_table.all?{|order_itemable| order_itemable.updated_at < 2.hours.ago}
      (self.guest_num == 1 && order_itemables_invalid(15.minutes.ago, user)) || (self.guest_num > 1 && order_itemables_invalid(60.minutes.ago, user))
    end

    def order_itemables_invalid(time_point, current_user)
      return false if order_itemable_of_current_table.blank?
      order_itemable_of_current_table.all?{|order_itemable|  (order_itemable.updated_at < time_point) && (order_itemable.base_user_id != current_user.id)}
    end

    def order_itemable_of_current_table
      @order_itemable_of_current_table ||= self.order_itemables.for_merge_order
    end

  end
end
