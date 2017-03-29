class FixZeroPriceGotNotActualAmount < ActiveRecord::Migration
  def change
    r = execute <<-SQL
      SELECT order_id from ddt_line_items where price = 0 and not_actual_amount != 0
    SQL
    order_ids = r.to_a.flatten
    if order_ids.present?
      count = order_ids.count
      puts "=========> Total: #{count}========================================"
      order_ids.each_slice(200).each_with_index do |oids, index|
        puts "==#{index}==#{oids.size}/#{count}====="
        Ddt::OrderService::Order::Base.includes(:line_items, :pay_items).find(oids).each do |order|
          order.update_line_item_not_actual_amount
          order.update_combo_package_item_adjustments
          order.save
        end
      end
    end
  end
end
