module Ddt
  class ReservationInfo < Ddt::Base
    include BelongsToBranch

    belongs_to_order name: :reservation_order
    belongs_to :table_zone
    belongs_to :reservation_time_point
    belongs_to :table
    delegate :name, to: :table_zone, prefix: true, allow_nil: true
    delegate :name, to: :table, prefix: true, allow_nil: true

    validates_presence_of :reservation_date, :table_zone, :reservation_time_point
    # , :name, :phone, :gender
    acts_as_type :gender, [:male, :female], %W[先生 女士]
    valid_phone :phone
    scope :active, ->{ where(active: true) }

    before_validation :reset_table_zone, if: :reservation_time_point_id_changed?
    set_from :reservation_time_point, targets: [:shop_id, :branch_id, :table_zone_id, :time_point]

    def reservation_time_info
      "#{self.table_zone_name} #{self.table_name} #{self.reservation_date.strftime('%F')} #{self.time_point_display}"
    end

    def reservation_customer_info
      "#{self.name} #{self.gender_name}(#{self.phone})"
    end

    def time_point_display
      self.time_point.try(:strftime, "%H:%M")
    end

    private
    def reset_table_zone
      self.table_zone_id = self.reservation_time_point.try(:table_zone_id)
    end
  end
end