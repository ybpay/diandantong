class ChangeTimeColumns < ActiveRecord::Migration
  def up
    change_column :ddt_combos, :start_time, :time, limit: 6, default: '2000-01-01 00:00:00.000000'
    change_column :ddt_combos, :end_time,   :time, limit: 6, default: '2000-01-01 23:59:59.000000'
    change_column :ddt_delivery_times, :start_time, :time, limit: 6
    change_column :ddt_delivery_times, :end_time, :time, limit: 6
    change_column :ddt_delivery_times, :cut_off_time, :time, limit: 6
    change_column :ddt_products, :start_time, :time, limit: 6, default: '2000-01-01 00:00:00.000000'
    change_column :ddt_products, :end_time,   :time, limit: 6, default: '2000-01-01 23:59:59.000000'
    change_column :ddt_queue_settings, :start_at, :time, limit: 6
    change_column :ddt_queue_settings, :end_at, :time, limit: 6
    change_column :ddt_reservation_infos, :time_point, :time, limit: 6
    change_column :ddt_reservation_time_points, :time_point, :time, limit: 6
    change_column :ddt_service_periods, :start_at, :time, limit: 6, default: '2000-01-01 09:00:00.000000'
    change_column :ddt_service_periods, :end_at,   :time, limit: 6, default: '2000-01-01 21:00:00.000000'
    change_column :ddt_time_intervals, :start, :time, limit: 6
  end

  def down
    change_column :ddt_combos, :start_time, :time, default: '2000-01-01 00:00:00.000000'
    change_column :ddt_combos, :end_time,   :time, default: '2000-01-01 23:59:59.000000'
    change_column :ddt_delivery_times, :start_time, :time
    change_column :ddt_delivery_times, :end_time, :time
    change_column :ddt_delivery_times, :cut_off_time, :time
    change_column :ddt_products, :start_time, :time, default: '2000-01-01 00:00:00.000000'
    change_column :ddt_products, :end_time,   :time, default: '2000-01-01 23:59:59.000000'
    change_column :ddt_queue_settings, :start_at, :time
    change_column :ddt_queue_settings, :end_at, :time
    change_column :ddt_reservation_infos, :time_point, :time
    change_column :ddt_reservation_time_points, :time_point, :time
    change_column :ddt_service_periods, :start_at, :time, default: '2000-01-01 09:00:00.000000'
    change_column :ddt_service_periods, :end_at,   :time, default: '2000-01-01 21:00:00.000000'
    change_column :ddt_time_intervals, :start, :time
  end
end
