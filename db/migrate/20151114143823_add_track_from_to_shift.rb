class AddTrackFromToShift < ActiveRecord::Migration
  def change
    "WECHAT, WEBPOS, WEBSTORE, APP, UNKNOW".split(',').map(&:strip).each do |track_from|
      add_column :ddt_shifts, "order_from_#{track_from.downcase}_count".to_sym, :integer, default: 0 unless column_exists? :ddt_shifts, "order_from_#{track_from.downcase}_count".to_sym
    end

    Ddt::Shift.find_each do |shift|
      shift.paid_orders.group(:track_from).count.each do |from, count|
        if from.present?
          from_name = from.underscore.split('_', 2).last
          shift.update!("order_from_#{from_name}_count" => count)
        end
      end
    end
  end
end
