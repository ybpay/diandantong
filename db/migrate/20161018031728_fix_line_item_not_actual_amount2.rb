class FixLineItemNotActualAmount2 < ActiveRecord::Migration
  def change
    start_time = Time.parse('2016-01-01')
    end_time = Time.parse('2016-10-19')
    dates = (start_time.to_i...end_time.to_i).step(1.day).map{|i| Time.at(i).strftime('%Y-%m-%d')}
    dates.each do |date|
      next_date = date.next
      r = ActiveRecord::Base.connection.execute <<-SQL
        select item.id from
          (select o.number, o.id, sum(l.not_actual_amount) as not_actual_amount from ddt_orders as o
            inner join ddt_line_items as l on o.id = l.order_id
            where o.pay_item_state = 'paid'
                and o.state = 'completed'
                and o.created_at > '#{date} 00:00:00'
                and o.created_at < '#{next_date} 00:00:00'
                and o.deleted_at IS NULL
                and l.quantity - l.subtract_quantity - l.move_quantity > 0
              group by l.order_id) as item
        inner join
          (select o.number, p.pay_method_name, o.id, sum(not_actual_amount) as not_actual_amount from ddt_orders as o
            inner join ddt_pay_items as p on o.id = p.order_id
            where o.pay_item_state = 'paid'
                and o.state = 'completed'
                and o.created_at > '#{date} 00:00:00'
                and o.created_at < '#{next_date} 00:00:00'
                and o.deleted_at IS NULL
                and p.deleted_at IS NULL
                and p.state = 'paid'
              group by p.order_id
              ) as pay_item on item.id = pay_item.id
        where item.not_actual_amount != pay_item.not_actual_amount;
      SQL
      order_ids = r.to_a.flatten
      if order_ids.present?
        count = order_ids.count
        puts "===#{date}======> #{count}========================================"
        order_ids.each_slice(200).each do |oids|
          puts "====#{oids.size}/#{count}====="
          Ddt::OrderService::Order::Base.includes(:line_items, :pay_items).find(oids).each do |order|
            order.update_line_item_not_actual_amount
            order.update_combo_package_item_adjustments
            order.save
          end
        end
      end
    end
  end
end
