# encoding:utf-8
module Ddt
  class TableZone < Ddt::Base
  	### relationships

    include Ddt::BelongsToBranch

    has_many :tables, class_name: 'Ddt::Table', inverse_of: :table_zone
    has_many :reservation_time_points, dependent: :destroy, class_name: 'Ddt::ReservationTimePoint'
    has_and_belongs_to_many :weixin_ban_products, join_table: 'ddt_weixin_ban_products', class_name: 'Ddt::Product'
    has_and_belongs_to_many :webpos_ban_products, join_table: 'ddt_webpos_ban_products', class_name: 'Ddt::Product'
    ids_string_for :weixin_ban_products, :webpos_ban_products

    ### validations
    validates :name, presence: true
    validates :min_reservation_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :reservation_price_percent, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
    validates :tables_count_for_reservation, presence: true, numericality: { greater_than_or_equal_to: 0 }


    ### callbacks
    before_destroy :check_tables
    touch_cache_version_of_scope :branch

    concerning :AdjustSource do
      def compute_amount_of_adjustment(order)
        self.reservation_price
      end

      def get_label_of_adjustment(order)
        "预订桌台订金"
      end
    end

    private
    def check_tables
      self.errors[:base] << "该桌台类型下有桌台,不能删除" if self.tables.count > 0
      self.errors.blank?
    end
  end
end
