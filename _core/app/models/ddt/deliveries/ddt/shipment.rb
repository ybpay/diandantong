# encoding:utf-8
module Ddt
  class Shipment < Ddt::Base
    include BelongsToBranch
    include LatLng
    include AASM
    belongs_to_order
    belongs_to :address
    belongs_to :delivery_zone
    belongs_to :delivery_time

    delegate :cost, :name, to: :delivery_zone, prefix: true, allow_nil: true
    delegate :display, :cost, to: :delivery_time, prefix: true, allow_nil: true
    delegate :name, :phone, :content, :lat_lng, to: :address, prefix: true

    set_from :address, targets: [:name, :phone, :content, :latitude, :longitude]
    filter_unicode_for :name

    scope :by_state, ->(state){ where(state: state) }

    record_state_change_for :state
    acts_as_type :state, [:pending, :shipping, :shipped, :canceled], %W(待处理 送货中 已送达 已取消)
    aasm column: :state do
      state :pending, :shipping, :shipped, :canceled, initial: :pending

      event :start do
        transitions from: :pending, to: :shipping
      end

      event :ship do
        transitions from: [:pending, :shipping], to: :shipped
      end

      event :cancel do
        transitions from: [:pending, :shipping], to: :canceled
      end

      after_transition to: :shipping, do: :after_shipping
      after_transition to: :shipped,  do: :after_ship
      after_transition to: :canceled, do: :after_cancel
    end

    def after_shipping
      touch :shipping_at
      append_note("--> #{operator_name} 把该次配送标记为送货中")
      Ddt::Notification::Event::Shipment::Started.create_and_send_notification(shipment: self)
    end

    def after_ship
      touch :shipped_at
      append_note("--> #{operator_name} 把该次配送标记为已送达")
      Ddt::Notification::Event::Shipment::Shipped.create_and_send_notification(shipment: self)
    end

    def after_cancel
      append_note("--> #{operator_name} 把该次配送标记为已取消")
      # TODO
    end

    def append_note(extra_note)
      self.update(note: "#{note}#{extra_note}")
    end

    def operator_name
      return "账户: #{Ddt::Account.current.name} (#{Ddt::Account.current.id})" if Ddt::Account.current.present?
      user = Ddt::BaseUser.current
      return "系统" if user.blank?
      "用户: #{user.vip_info.name} (user.id)"
    end

    def total
      cost
    end

    def calculate_cost(cart: nil)
      order = self.order || cart
      if order.is_FromWechat?
        self.cost = branch.delivery_setting.calculate_delivery_fee(self)
      else
        self.cost = 0
      end
    end

    def distance_to_branch
      lat_lng.compact.present? ? branch.distance_to(lat_lng, units: :kms) : 1000
    end
    alias_method :delivery_distance, :distance_to_branch

    concerning :DeliveryMan do
      included do
        belongs_to :delivery_man, class_name: 'Ddt::Account'
        after_save :assign_change, if: :delivery_man_id_changed?
        before_validation :assert_assign_delivery_man, if: :delivery_man_id_changed?
      end

      def assign_change
        change = self.changes[:delivery_man_id]
        pre   = change[0]
        after = change[1]
        unless pre.blank?
          Ddt::Notification::Event::Shipment::Unassigned.create_and_send_notification(shipment: self, delivery_man_id: pre)
        end
        unless after.blank?
          Ddt::Notification::Event::Shipment::Assigned.create_and_send_notification(shipment: self)
        end
      end

      def deliveryman_location
        return nil if state != "shipping" || delivery_man.blank?
        delivery_man.locations.last
      end

      def assign_delivery_man?
        delivery_man.present? rescue false
      end

      def assign_delivery_man(delivery_man_id)

       self.update(delivery_man_id: delivery_man_id)
      end

      private
      def assert_assign_delivery_man
        self.errors.add(:delivery_man, '订单成完成状态，或者配送已经开始或完成，不可重指定配送员') if (order.completed? or [:shipping, :shipped].include? self.state.to_sym)
      end
    end
  end
end
