module Ddt
  class DeliverySetting < Ddt::Base
    include Ddt::BelongsToBranchWithTouch


    delegate :shop, to: :branch
    has_many :delivery_times, dependent: :destroy, inverse_of: :delivery_setting
    accepts_nested_attributes_for :delivery_times, allow_destroy: true
    has_many :distance_ranges

    validates :support_delivery_if_amount_gt, :min_delivery_fee, :delivery_radius, numericality: { greater_than_or_equal_to: 0 }, presence: true
    validates :receive_delivery_order_within_days, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 365 }, presence: true
    validates :delivery_need_minutes, numericality: { greater_than: 0 }, presence: true

    validates_presence_of :charge_by
    validates :per_unit_cost, :unit, presence: true, numericality: { greater_than: 0}, if: :is_per_unit?
    after_save :update_branch_min_delivery_fee

    acts_as_type(:charge_by, [:zone, :per_unit, :range, :delivery_time],
      [ I18n.t("activerecord.attributes.ddt/delivery_setting.zone"),
        I18n.t("activerecord.attributes.ddt/delivery_setting.per_unit"),
        I18n.t("activerecord.attributes.ddt/delivery_setting.range"),
        I18n.t("activerecord.attributes.ddt/delivery_setting.delivery_time")
    ])

    acts_as_type(:assign_mode, [:active, :passive],
      [ I18n.t("activerecord.attributes.ddt/delivery_setting.active"),
        I18n.t("activerecord.attributes.ddt/delivery_setting.passive"),
    ])


    def delivery_dates
      start = today_can_order? ? 0 : 1
      (start..receive_delivery_order_within_days).to_a.map do |days_from_now|
        date = days_from_now.days.from_now.in_time_zone(self.shop.time_zone).beginning_of_day.to_date
        times = self.delivery_times.valid(today: date.today?)
        {
          date: date,
          display: date_display(days_from_now),
          delivery_times: times.map{|t| {id: t.id, display: t.display}}
        }
      end
    end

    def date_display(days_from_now)
      if days_from_now == 0
        I18n.t("activerecord.attributes.ddt/delivery_setting.date_displays.today")
      elsif days_from_now == 1
        I18n.t("activerecord.attributes.ddt/delivery_setting.date_displays.tomorrow")
      else
        days_from_now.days.from_now.in_time_zone(self.shop.time_zone).strftime("%Y-%m-%d")
      end
    end

    def today_can_order?
      !use_fixed_delivery_time || delivery_times.valid.present?
    end

    def is_charge_by_distance
      %W[per_unit range].include? charge_by
    end

    def calculate_delivery_fee(shipment)
      case self.charge_by.to_sym
      when :zone
        shipment.delivery_zone_cost || 0.0
      when :per_unit
        return 0 if self.unit == 0
        distance = shipment.delivery_distance
        return 0 if distance == 0
        # 小于一公里以一公里算
        return (1.0/self.unit * self.per_unit_cost).round(2) if distance < 1
        # 大于一公里以四舍五入算
        cost = (distance.to_f/self.unit).round * self.per_unit_cost
        cost.round(2)
      when :range
        distance = shipment.delivery_distance
        return 0 if distance == 0
        Ddt::DeliveryRange.get_distance_cost(branch.delivery_ranges, distance)
      when :delivery_time
        shipment.delivery_time_cost || 0.0
      end
    end

    def update_branch_min_delivery_fee
      if charge_by == "per_unit"
        self.update_column(:min_delivery_fee, self.per_unit_cost)
      end
    end

    def default_shipment(address: nil)
      Ddt::Shipment.new(
        branch: self.branch,
        address: address,
        delivery_zone: default_delivery_zone,
        delivery_date: default_delivery_date,
        delivery_time: default_delivery_time
      )
    end

    def default_delivery_zone
      self.is_charge_by_distance ? nil : self.branch.delivery_zones.first
    end

    def default_delivery_date
      self.branch.delivery_dates[0][:date] rescue Date.current
    end

    def default_delivery_time
      self.delivery_times.valid.first
    end

  end
end
