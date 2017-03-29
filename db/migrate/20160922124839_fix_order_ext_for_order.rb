class FixOrderExtForOrder < ActiveRecord::Migration
  def change
    result = ActiveRecord::Base.connection.execute <<-SQL
        select o.id from ddt_orders as o
          left join ddt_order_exts as e
          on o.id = e.order_id
        where e.order_id IS NULL
    SQL
    order_ids = result.to_a.flatten
    order_ids.each_slice(200).to_a.each do |oids|
      puts "#{oids.size}/#{order_ids.size} such as #{oids[0]}"
      Ddt::OrderService::Order::Base.find(oids).each do |order|
        order.create_order_ext if order.order_ext.blank?
      end
    end
  end
end
