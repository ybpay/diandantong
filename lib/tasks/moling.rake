namespace :moling do
  task :fix => :environment do |t, args|
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
            inner join ddt_adjustments as a on o.id = a.order_id
          where
            o.shop_id = #{shop.id}
            AND o.state in ('completed', 'confirmed')
            AND o.deleted_at is NULL
            AND a.deleted_at is NULL
            AND a.reason = "moling"
            AND o.paid_at between '#{start_time.strftime("%F %T")}' and '#{end_time.strftime("%F %T")}'
            AND o.type in ('Ddt::DeliveryOrder', 'Ddt::EatInHallOrder', 'Ddt::FastfoodOrder');
        SQL
        order_ids = ActiveRecord::Base.connection.execute(sql).to_a.flatten
        order_count = order_ids.count
        order_ids.each_with_index do |id, index|
          order = Ddt::OrderService::Orders.find(id)
          moling_adjustment = order.adjustments.moling.first
          if moling_adjustment.present?
            order.moling_amount = moling_adjustment.amount
            if moling_adjustment.item_adjustments.present?
              moling_adjustment.item_adjustments.each do |item_adjustment|
                line_item = order.line_items.find(item_adjustment.line_item_id)
                if line_item.present?
                  line_item.apportion_adjustment_total -= item_adjustment.amount
                  line_item.apportion_adjust_reason = line_item.apportion_adjust_reason.gsub("moling", "")
                end
              end
            end
            order.adjustment_total -= moling_adjustment.amount
            moling_adjustment.destroy
            # p order.all_changed_values
            order.save
          end
          p "===== order_id: #{order.id} ===== #{index+1}/#{order_count} ====="
        end
        # 更新交班记录
        sql = <<-SQL
          update ddt_shifts s
          set s.discount_amount = s.discount_amount - s.moling_amount
          where
            s.shop_id = #{shop.id}
            and s.state = "closed"
            and s.created_at > '2016-01-01 00:00:00.000000';
        SQL
        ActiveRecord::Base.connection.execute(sql)
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
        inner join ddt_adjustments as a on o.id = a.order_id
      where
        o.state in ('completed', 'confirmed')
        AND o.deleted_at is NULL
        AND a.deleted_at is NULL
        AND a.reason = "moling"
        AND o.paid_at between '#{start_time.strftime("%F %T")}' and '#{end_time.strftime("%F %T")}'
        AND o.type in ('Ddt::DeliveryOrder', 'Ddt::EatInHallOrder', 'Ddt::FastfoodOrder');
    SQL
    order_ids = ActiveRecord::Base.connection.execute(sql).to_a.flatten
    order_count = order_ids.count
    order_ids.each_with_index do |id, index|
      order = Ddt::OrderService::Orders.find(id)
      moling_adjustment = order.adjustments.moling.first
      if moling_adjustment.present?
        order.moling_amount = moling_adjustment.amount
        if moling_adjustment.item_adjustments.present?
          moling_adjustment.item_adjustments.each do |item_adjustment|
            line_item = order.line_items.find(item_adjustment.line_item_id)
            if line_item.present?
              line_item.apportion_adjustment_total -= item_adjustment.amount
              line_item.apportion_adjust_reason = line_item.apportion_adjust_reason.gsub("moling", "")
            end
          end
        end
        order.adjustment_total -= moling_adjustment.amount
        moling_adjustment.destroy
        # p order.all_changed_values
        order.save
      end
      p "===== order_id: #{order.id} ===== #{index+1}/#{order_count} ====="
    end
  end
end