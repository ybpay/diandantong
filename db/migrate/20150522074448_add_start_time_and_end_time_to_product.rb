class AddStartTimeAndEndTimeToProduct < ActiveRecord::Migration
  def change
    add_column :ddt_products, :start_time, :time, default: '00:00:00'
    add_column :ddt_products, :end_time, :time, default: '23:59:59'
    add_column :ddt_combos, :start_time, :time, default: '00:00:00'
    add_column :ddt_combos, :end_time, :time, default: '23:59:59'
  end
end
