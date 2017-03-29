class FixAppendNotActualAmount < ActiveRecord::Migration
  def up
    sql = <<-SQL
      select o.id
      from ddt_orders o
      inner join ddt_pay_items as p on p.order_id = o.id
      where
        o.delete_by_admin = 0 and
        o.placed_at > '2016-01-01 00:00' and
        o.pay_item_state = 'paid' and
        p.deleted_at is NULL and
        p.is_append = 1
    SQL
    order_ids = execute(sql).to_a.flatten
    count = order_ids.count
    puts "============== order_ids count: #{count} =============="
    order_ids.each_with_index do |order_id, index|
      order = Ddt::OrderService::Order::Base.find(order_id)
      puts "============= #{order_id} shop_id:#{order.shop_id}=== #{index}/#{count} ========"
      order.update_line_item_not_actual_amount
      order.update_combo_package_item_adjustments
      order.save
    end
  end

  def down
  end
end
