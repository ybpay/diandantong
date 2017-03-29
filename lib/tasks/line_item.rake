namespace :line_item do
  task :not_actual_amount => :environment do |t, args|
    shop_id = ENV['shop_id']
    if shop_id.present?
      shop = ::Ddt::Shop.find_by(id: shop_id)
      if shop.present?
        p "#{shop.name} id:#{shop_id}"
        start_time = Time.parse("2016-01-01 00:00:00 +0800")
        end_time = Time.now
        sql = <<-SQL
          select distinct
            o.id
          from ddt_orders as o
            inner join ddt_pay_items as p on o.id = p.order_id
            inner join ddt_line_items as l on o.id = l.order_id
          where
            o.shop_id = #{shop.id}
            AND o.state in ('completed', 'confirmed')
            AND o.deleted_at is NULL
            AND p.deleted_at is NULL
            AND l.deleted_at is NULL
            AND l.is_subtract = 0
            AND l.is_moved = 0
            AND l.price > 0
            AND (l.quantity - l.subtract_quantity - l.move_quantity) > 0
            AND l.not_actual_amount = 0
            AND p.pay_method_percent_of_actual < 100
            AND o.paid_at between '#{start_time.strftime("%F %T")}' and '#{end_time.strftime("%F %T")}'
            AND o.type in ('Ddt::DeliveryOrder', 'Ddt::EatInHallOrder', 'Ddt::FastfoodOrder');
        SQL
        order_ids = ActiveRecord::Base.connection.execute(sql).to_a.flatten
        order_count = order_ids.count
        order_ids.each_with_index do |id, index|
          order = Ddt::OrderService::Orders.find(id)
          order.update_line_item_not_actual_amount
          # p order.all_changed_values
          order.save
          p "===== order_id: #{order.id} ===== #{index+1}/#{order_count} ====="
        end
      end
    end
  end

  task :fix_all => :environment do |t, args|
    start_time = Time.parse("2016-01-01 00:00:00 +0800")
    end_time = Time.now
    sql = <<-SQL
      select distinct
        o.id
      from ddt_orders as o
        inner join ddt_pay_items as p on o.id = p.order_id
        inner join ddt_line_items as l on o.id = l.order_id
      where
        o.state in ('completed', 'confirmed')
        AND o.deleted_at is NULL
        AND p.deleted_at is NULL
        AND l.deleted_at is NULL
        AND l.is_subtract = 0
        AND l.is_moved = 0
        AND l.price > 0
        AND (l.quantity - l.subtract_quantity - l.move_quantity) > 0
        AND l.not_actual_amount = 0
        AND p.pay_method_percent_of_actual < 100
        AND o.paid_at between '#{start_time.strftime("%F %T")}' and '#{end_time.strftime("%F %T")}'
        AND o.type in ('Ddt::DeliveryOrder', 'Ddt::EatInHallOrder', 'Ddt::FastfoodOrder');
    SQL
    order_ids = ActiveRecord::Base.connection.execute(sql).to_a.flatten
    order_count = order_ids.count
    order_ids.each_with_index do |id, index|
      order = Ddt::OrderService::Orders.find(id)
      order.update_line_item_not_actual_amount
      # p order.all_changed_values
      order.save
      p "===== order_id: #{order.id} ===== #{index+1}/#{order_count} ====="
    end
  end

  task :fix_vip_card_pay => :environment do |t, args|
    start_time = Time.parse("2016-01-01 00:00:00 +0800")
    end_time = Time.now
    sql = <<-SQL
      select distinct
        o.id
      from ddt_orders as o
        inner join ddt_pay_items as p on o.id = p.order_id
        inner join ddt_line_items as l on o.id = l.order_id
      where
        o.state in ('completed', 'confirmed')
        AND o.deleted_at is NULL
        AND p.deleted_at is NULL
        AND l.deleted_at is NULL
        AND l.is_subtract = 0
        AND l.is_moved = 0
        AND l.price > 0
        AND (l.quantity - l.subtract_quantity - l.move_quantity) > 0
        AND l.not_actual_amount = 0
        AND p.pay_method_name_sym = "vip_card_pay"
        AND o.paid_at between '#{start_time.strftime("%F %T")}' and '#{end_time.strftime("%F %T")}'
        AND o.type in ('Ddt::DeliveryOrder', 'Ddt::EatInHallOrder', 'Ddt::FastfoodOrder');
    SQL
    order_ids = ActiveRecord::Base.connection.execute(sql).to_a.flatten
    order_count = order_ids.count
    order_ids.each_with_index do |id, index|
      p "start to migrate for order: #{id}"
      order = Ddt::OrderService::Orders.find(id)
      order.update_line_item_not_actual_amount
      # p order.all_changed_values
      order.save
      p "===== order_id: #{order.id} ===== #{index+1}/#{order_count} ====="
    end
  end
end