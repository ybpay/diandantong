class FixVipCardPayNotActualAmount < ActiveRecord::Migration
  def up
    sql = <<-SQL
      select o.id
      from ddt_orders as o
      inner join ddt_pay_items as p on p.order_id = o.id
      where
        o.pay_item_state = 'paid' and
        p.pay_method_name_sym = 'vip_card_pay' and
        o.delete_by_admin = 0 and
        p.deleted_at is null and
        o.placed_at > '2016-01-01 00:00:00';
    SQL
    order_ids = execute(sql).to_a.flatten
    order_count = order_ids.count
    puts "============== order_count = #{order_count} ============="
    order_ids.each_with_index do |order_id, index|
      puts "============== #{order_id} ==== #{(index * 100.0 / order_count).round(2)}% ============="
      order = Ddt::OrderService::Order::Base.find(order_id)
      order.update_line_item_not_actual_amount
      order.update_combo_package_item_adjustments
      order.save
    end
  end

  def down
  end
end
