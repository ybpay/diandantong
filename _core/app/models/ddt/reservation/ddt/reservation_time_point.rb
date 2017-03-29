module Ddt
  class ReservationTimePoint < Ddt::Base
    include Ddt::BelongsToBranch
    replicated_model

  	### relationships
    belongs_to :table_zone, class_name: 'Ddt::TableZone'

    set_from :table_zone
    has_many :reservation_infos, class_name: 'Ddt::ReservationInfo'
    validates :time_point, presence: true
    ### validations
    ### callbacks

    def order_counts_in_max_reservation_days
      md = self.branch.reservation_setting.max_reservation_days
      all_infos = self.reservation_infos.active.where(reservation_time_point_id: self.id, reservation_date: Date.today...md.days.from_now.to_date).to_a
      (0...md).map do |t|
        all_infos.count{ |info| info.reservation_date.strftime('%F') == t.days.from_now.to_date.strftime('%F')}
      end
    end

    def reserved_tables(date)
      reserved_table_ids = self.reservation_infos.active.where(reservation_date: date..date.next).where.not(table_id: nil).pluck(:table_id)
      reserved_tables = self.table_zone.tables.find(reserved_table_ids)
    end

    def valid_today?
      Ddt::TimeUtil.time_a_early_than_b(shop_time_now, self.time_point)
    end

    private
      def time_zone
        return self.shop.time_zone if shop_id.present?
        self.branch.shop.time_zone
      end

  end
end
