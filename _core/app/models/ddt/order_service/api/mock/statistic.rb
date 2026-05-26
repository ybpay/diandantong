module Ddt
  module OrderService
    module Api
      module Mock
        class Statistic
          def self.order_quantity(options={})
            query_params = options[:query]
            count_params = options[:count] || "*"
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_order_columns.include?(name)
                name
              elsif group_by_time_types(:placed_at).include?(name.to_sym)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              elsif group_by_time_types(:paid_at).include?(name.to_sym)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              Model::Order.ransack(query_params).result.count(count_params)
            else
              result = Model::Order.group(group_by_columns).ransack(query_params).result.count(count_params)
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.orders(options={})
            query_params = options[:query]
            Model::Order.select('id, number, total').where(pay_item_state: :paid).ransack(query_params).result.map do |o|
              {
                id: o.id,
                number: o.number,
                total: o.total
              }
            end
          end

          def self.order_times_total(options={})
            query_params = options[:query]
            custom_where_clause = options[:where] || 1
            group_by_names = Array(options[:group_by]).flatten
            select_columns = 'count(*) as times, sum(ddt_orders.adjustment_total) as adjustment_total, sum(ddt_orders.total) as total, sum(guest_num) as guest_num'
            group_by_columns = group_by_names.map(&:to_sym).map{|name|
              if group_by_order_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name.to_sym)
                group_by_time_type_to_sql_simple(name, table_name: :ddt_orders)
              end
            }.compact.first(2)

            select_by_columns = group_by_names.map(&:to_sym).map{|name|
              if group_by_order_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name.to_sym)
                select_by_time_type_to_sql_simple(name, table_name: :ddt_orders)
              end
            }.compact.first(2)

            if group_by_columns.count == 0
              Model::Order.select(select_columns).where(pay_item_state: :paid).where(custom_where_clause).ransack(query_params).result
            else
              Model::Order.select(select_columns + ", "+select_by_columns.join(",")).where(pay_item_state: :paid).where(custom_where_clause).group(group_by_columns).ransack(query_params).result
            end

          end

          def self.order_sale_amount(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_order_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              Model::Order.where(pay_item_state: :paid).ransack(query_params).result.sum(:pay_item_total)
            else
              result = Model::Order.where(pay_item_state: :paid).group(group_by_columns).ransack(query_params).result.sum(:pay_item_total)
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.order_amount(options={})
            query_params = options[:query]
            Model::Order.ransack(query_params).result.sum(:total)
          end

          def self.order_moling_amount(options={})
            query_params = options[:query]
            Model::Order.ransack(query_params).result.sum(:moling_amount)
          end

          def self.line_item_quantity(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map{ |name|
              if group_by_line_item_columns.include?(name)
                name
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              Model::LineItem.ransack(query_params).result.sum(:quantity)
            else
              result = Model::LineItem.group(group_by_columns).ransack(query_params).result.sum(:quantity)
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.variant_sale_quantity(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by] || :itemable_name)
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_line_item_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              result = Model::LineItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, itemable_type: "Ddt::Variant", is_subtract: false, is_moved: false)
                            .reorder("sum(quantity - subtract_quantity - move_quantity) desc")
                            .ransack(query_params).result.sum("quantity - subtract_quantity - move_quantity")
            else
              result = Model::LineItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, itemable_type: "Ddt::Variant", is_subtract: false, is_moved: false)
                            .reorder("sum(quantity - subtract_quantity - move_quantity) desc")
                            .group(group_by_columns)
                            .ransack(query_params).result.sum("quantity - subtract_quantity - move_quantity")
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.variant_sale_amount(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by] || :itemable_name).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_line_item_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              result = Model::LineItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, itemable_type: "Ddt::Variant", is_subtract: false, is_moved: false)
                            .reorder("sum((quantity - subtract_quantity - move_quantity) * price - ddt_line_items.adjustment_total - ddt_line_items.apportion_adjustment_total) desc")
                            .ransack(query_params).result.sum("(quantity - subtract_quantity - move_quantity) * price - ddt_line_items.adjustment_total - ddt_line_items.apportion_adjustment_total")
            else
              result = Model::LineItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, itemable_type: "Ddt::Variant", is_subtract: false, is_moved: false)
                            .reorder("sum((quantity - subtract_quantity - move_quantity) * price - ddt_line_items.adjustment_total - ddt_line_items.apportion_adjustment_total) desc")
                            .group(group_by_columns)
                            .ransack(query_params).result.sum("(quantity - subtract_quantity - move_quantity) * price - ddt_line_items.adjustment_total - ddt_line_items.apportion_adjustment_total")
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.combo_sale_quantity(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by] || :product_name).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_line_item_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              result = Model::LineItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, itemable_type: "Ddt::ComboPackage", is_subtract: false, is_moved: false)
                            .reorder("sum(quantity - subtract_quantity - move_quantity) desc")
                            .ransack(query_params).result.sum("quantity - subtract_quantity - move_quantity")
            else
              result = Model::LineItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, itemable_type: "Ddt::ComboPackage", is_subtract: false, is_moved: false)
                            .reorder("sum(quantity - subtract_quantity - move_quantity) desc")
                            .group(group_by_columns)
                            .ransack(query_params).result.sum("quantity - subtract_quantity - move_quantity")
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.combo_sale_amount(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by] || :product_name).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_line_item_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              result = Model::LineItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, itemable_type: "Ddt::ComboPackage", is_subtract: false, is_moved: false)
                            .reorder("sum((quantity - subtract_quantity - move_quantity) * price - ddt_line_items.adjustment_total - ddt_line_items.apportion_adjustment_total) desc")
                            .ransack(query_params).result.sum("(quantity - subtract_quantity - move_quantity) * price - ddt_line_items.adjustment_total - ddt_line_items.apportion_adjustment_total")
            else
              result = Model::LineItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, itemable_type: "Ddt::ComboPackage", is_subtract: false, is_moved: false)
                            .reorder("sum((quantity - subtract_quantity - move_quantity) * price - ddt_line_items.adjustment_total - ddt_line_items.apportion_adjustment_total) desc")
                            .group(group_by_columns)
                            .ransack(query_params).result.sum("(quantity - subtract_quantity - move_quantity) * price - ddt_line_items.adjustment_total - ddt_line_items.apportion_adjustment_total")
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.combo_item_list(options={})
            query_params = options[:query]
            where = options[:where]

            Model::LineItem.includes(:order).references(:ddt_orders)
                 .where(ddt_orders: {pay_item_state: :paid})
                 .where(itemable_type: 'Ddt::ComboPackage', is_subtract: false, is_moved: false)
                 .where('(quantity - subtract_quantity - move_quantity) > 0')
                 .where(where)
                 .ransack(query_params).result.map do |line_item|
              {
                product_name: line_item[:product_name],
                itemable_id:  line_item[:itemable_id],
                itemable_name: line_item[:itemable_name],
                original_price: line_item[:original_price],
                price: line_item[:price],
                quantity: line_item[:quantity] - line_item[:subtract_quantity] - line_item[:move_quantity],
                adjustment_total: (line_item[:adjustment_total] || 0) + (line_item[:apportion_adjustment_total] || 0),
                not_actual_amount: (line_item[:not_actual_amount] || 0)
              }
            end
          end

          def self.line_item_list(options={})
            skus = options[:skus]
            shop_id = options[:shop_id]
            start_time_gt = options[:start_time_gt]
            start_time_gteq = options[:start_time_gteq]
            end_time_lt = options[:end_time_lt]
            end_time_lteq = options[:end_time_lteq]

            extra_condition = ''
            extra_condition += "AND o.paid_at > '#{to_sql_time(start_time_gt)}'" if start_time_gt.present?
            extra_condition += "AND o.paid_at >= '#{to_sql_time(start_time_gteq)}'" if start_time_gteq.present?
            extra_condition += "AND o.paid_at < '#{to_sql_time(end_time_lt)}'" if end_time_lt.present?
            extra_condition += "AND o.paid_at <= '#{to_sql_time(end_time_lteq)}'" if end_time_lteq.present?

            sql = <<-SQL
              SELECT
                l.sku,
                l.branch_id,
                any_value(l.itemable_type),
                any_value(l.product_name),
                any_value(l.itemable_name),
                any_value(l.category_names),
                sum(l.quantity - l.subtract_quantity - l.move_quantity) as quantity,
                sum((l.quantity - l.subtract_quantity - l.move_quantity) * l.price) as amount,
                sum(l.adjustment_total + l.apportion_adjustment_total) as adjustment_total,
                sum(l.not_actual_amount) as not_actual_amount
              FROM
                  ddt_line_items as l
                      INNER JOIN ddt_orders as o ON o.id = l.order_id
              WHERE
                  o.deleted_at IS NULL
                      AND o.type in ("Ddt::EatInHallOrder", "Ddt::DeliveryOrder", "Ddt::FastfoodOrder")
                      AND l.shop_id = #{shop_id}
                      AND l.is_subtract = 0
                      AND l.is_moved = 0
                      AND (quantity - subtract_quantity - move_quantity) > 0
                      #{"AND l.sku in ('#{skus.join('\',\'')}')" if skus.present?}
                      #{extra_condition}
              GROUP BY l.sku , l.branch_id;
            SQL
            result = ActiveRecord::Base.connection.execute(sql).to_a
            result.map{|l|
              {
                sku: l[0],
                branch_id: l[1],
                itemable_type: l[2],
                product_name: l[3],
                itemable_name: l[4],
                category_names: l[5],
                quantity: l[6],
                amount: l[7],
                adjustment_total: l[8],
                not_actual_amount: l[9],
              }
            }
          end

          def self.gift_item_list(options={})
            query_params = options[:query]
            result =  Model::LineItem.includes(:order).references(:ddt_orders)
                          .where(ddt_orders: { pay_item_state: :paid })
                          .where(gift: true)
                          .ransack(query_params).result
            if options[:page].present?
              result = result.paginate(page: options[:page])
            end
            result.map{|line_item|
              {
                branch_id:       line_item.branch_id,
                order_id:        line_item.order.id,
                order_number:    line_item.order.number,
                table_name:      line_item.order.table_name,
                table_zone_name: line_item.order.table_zone_name,
                waiter_id:       line_item.order.waiter_id,
                created_at:      line_item.created_at.strftime("%F %T"),
                itemable_type:   line_item.itemable_type,
                itemable_id:     line_item.itemable_id,
                itemable_name:   line_item.itemable_name,
                product_name:    line_item.product_name,
                quantity:        line_item.quantity - line_item.subtract_quantity - line_item.move_quantity,
                original_price:  (line_item.original_price || 0),
                gift_reason:     line_item.gift_reason
              }
            }
          end

          def self.subtract_item_list(options={})
            query_params = options[:query]
            result =  Model::LineItem.includes(:order).references(:ddt_orders)
                          .includes(:order_change_log).references(:ddt_order_change_log)
                          .where(ddt_orders: { pay_item_state: :paid })
                          .where(is_subtract: true)
                          .ransack(query_params).result
            if options[:page].present?
              result = result.paginate(page: options[:page])
            end
            result.map{|line_item|
              {
                order_number:    line_item.order.number,
                order_id:        line_item.order.id,
                table_name:      line_item.order.table_name,
                table_zone_name: line_item.order.table_zone_name,
                placed_at:       line_item.order.placed_at,
                created_at:      line_item.created_at.strftime("%F %T"),
                itemable_type:   line_item.itemable_type,
                itemable_id:     line_item.itemable_id,
                itemable_name:   line_item.itemable_name,
                product_name:    line_item.product_name,
                quantity:        line_item.quantity,
                price:           line_item.price,
                subtract_reason: line_item.subtract_reason,
                operator_id:     line_item.order_change_log.operator_id,
                operator_type:   line_item.order_change_log.operator_type,
                operator_name:   line_item.order_change_log.operator_name,
                settle_account_id: line_item.order.settle_account_id,
                source_line_item_id: line_item.source_line_item_id
              }
            }
          end

          def self.serve_detail(options={})
            shop_id_eq   = options[:query][:shop_id_eq]
            branch_id_eq = options[:query][:branch_id_eq]
            paid_at_gteq = options[:query][:paid_at_gteq]
            paid_at_lt   = options[:query][:paid_at_lt]
            paid_at_lteq = options[:query][:paid_at_lteq]
            order_type_in= options[:query][:order_type_in]
            extra_condition = []
            extra_condition << "o.shop_id = #{shop_id_eq}" if shop_id_eq.present?
            extra_condition << "o.branch_id = #{branch_id_eq}" if branch_id_eq.present?
            extra_condition << "o.paid_at >= '#{to_sql_time(paid_at_gteq)}'" if paid_at_gteq.present?
            extra_condition << "o.paid_at < '#{to_sql_time(paid_at_lt)}'" if paid_at_lt.present?
            extra_condition << "o.paid_at <= '#{to_sql_time(paid_at_lteq)}'" if paid_at_lteq.present?
            extra_condition << "o.type in ('#{order_type_in.join('\',\'')}')" if order_type_in.present?
            sql = <<-SQL
              SELECT
                waiter_id,
                itemable_name,
                sum(quantity - subtract_quantity - move_quantity) as quantity,
                sum((quantity - subtract_quantity - move_quantity) * price) as amount,
                any_value(price)
              FROM
                  ddt_line_items as l
                      INNER JOIN ddt_orders as o ON o.id = l.order_id
              WHERE
                  o.deleted_at IS NULL
                      AND o.pay_item_state = 'paid'
                      AND l.is_subtract = 0
                      AND l.is_moved = 0
                      AND (quantity - subtract_quantity - move_quantity) > 0
                      #{extra_condition.present? ? " AND #{extra_condition.join(' AND ')}" : ""}
              GROUP BY o.waiter_id , l.itemable_name;
            SQL
            ActiveRecord::Base.connection.execute(sql).to_a.map do |item|
              {
                waiter_id:      item[0],
                itemable_name:  item[1],
                quantity:       item[2],
                amount:         item[3],
                price:          item[4]
              }
            end
          end

          def self.variant_sale_summary(options={})
            group = options[:group] || :itemable_id
            itemable_id_in = options[:query][:itemable_id_in]
            sku_in = options[:query][:sku_in]
            order_id_eq = options[:query][:order_id_eq]
            shop_id_eq = options[:query][:shop_id_eq]
            branch_id_in = options[:query][:branch_id_in]
            branch_id_eq = options[:query][:branch_id_eq]
            pay_item_state_eq = (options[:query][:pay_item_state_eq]  || 'paid')
            placed_at_gteq = options[:query][:placed_at_gteq]
            placed_at_gt = options[:query][:placed_at_gt]
            placed_at_lteq = options[:query][:placed_at_lteq]
            placed_at_lt = options[:query][:placed_at_lt]
            paid_at_gteq = options[:query][:paid_at_gteq]
            paid_at_gt = options[:query][:paid_at_gt]
            paid_at_lteq = options[:query][:paid_at_lteq]
            paid_at_lt = options[:query][:paid_at_lt]
            where = options[:where] || 1

            select_group_columns = []
            select_group_columns << (group.to_sym == :sku ? "any_value(l.sku)" : "l.sku")
            select_group_columns << (group.to_sym == :itemable_id ? "any_value(l.itemable_id)" : "l.itemable_id")
            select_group_column_str = select_group_columns.join(', ')

            extra_condition = []
            extra_condition << "l.itemable_id in (#{itemable_id_in.join(',')})" if itemable_id_in.present?
            extra_condition << "l.sku in (#{sku_in.map{|i| "'%s'" % i}.join(',')})" if sku_in.present?
            extra_condition << "o.id = #{order_id_eq}" if order_id_eq.present?
            extra_condition << "o.shop_id=#{shop_id_eq}" if shop_id_eq.present?
            extra_condition << "o.branch_id = #{branch_id_eq}" if branch_id_eq.present?
            extra_condition << "o.branch_id in (#{branch_id_in.join(',')})" if branch_id_in.present?
            extra_condition << "o.pay_item_state = '#{pay_item_state_eq}'" if pay_item_state_eq == 'paid'
            extra_condition << "o.pay_item_state in ('none', 'unpaid')" if pay_item_state_eq == 'unpaid'
            extra_condition << "o.paid_at >= '#{to_sql_time(paid_at_gteq)}'" if paid_at_gteq.present?
            extra_condition << "o.paid_at > '#{to_sql_time(paid_at_gt)}'" if paid_at_gt.present?
            extra_condition << "o.paid_at <= '#{to_sql_time(paid_at_lteq)}'" if paid_at_lteq.present?
            extra_condition << "o.paid_at < '#{to_sql_time(paid_at_lt)}'" if paid_at_lt.present?
            extra_condition << where
            extra_condition << "o.placed_at >= '#{to_sql_time(placed_at_gteq)}'" if placed_at_gteq.present?
            extra_condition << "o.placed_at > '#{to_sql_time(placed_at_gt)}'" if placed_at_gt.present?
            extra_condition << "o.placed_at <= '#{to_sql_time(placed_at_lteq)}'" if placed_at_lteq.present?
            extra_condition << "o.placed_at < '#{to_sql_time(placed_at_lt)}'" if placed_at_lt.present?

            sql = <<-SQL
              SELECT
                category_names,
                any_value(itemable_name),
                sum(quantity - subtract_quantity - move_quantity) as quantity,
                sum((quantity - subtract_quantity - move_quantity) * price) as amount,
                sum(l.adjustment_total) + sum(l.apportion_adjustment_total) as adjustment_total,
                sum(l.not_actual_amount) as not_actual_amount,
                any_value(price),
                #{select_group_column_str}
              FROM
                  ddt_line_items as l
                      INNER JOIN ddt_orders as o ON o.id = l.order_id
              WHERE
                  o.deleted_at IS NULL
                      AND l.itemable_type = 'Ddt::Variant'
                      AND l.is_subtract = 0
                      AND l.is_moved = 0
                      AND (quantity - subtract_quantity - move_quantity) > 0
                      #{extra_condition.present? ? " AND #{extra_condition.join(' AND ')}" : ""}
              GROUP BY l.category_names , l.#{group};
            SQL
            ActiveRecord::Base.connection.execute(sql).to_a.map do |item|
              {
                category_names: item[0],
                itemable_name:  item[1],
                quantity:       item[2],
                amount:         item[3],
                adjustment_amount: (item[4] || 0),
                adjustment_total: (item[4] || 0),
                not_actual_amount: (item[5] || 0),
                price:          item[6],
                sku:            item[7],
                itemable_id:    item[8]
              }
            end
          end

          def self.combo_sale_summary(options={})
            group = options[:group] || :itemable_id
            itemable_id_in = options[:query][:itemable_id_in]
            shop_id_eq = options[:query][:shop_id_eq]
            branch_id_in = options[:query][:branch_id_in]
            branch_id_eq = options[:query][:branch_id_eq]
            pay_item_state_eq = (options[:query][:pay_item_state_eq]  || 'paid')
            placed_at_gteq = options[:query][:placed_at_gteq]
            placed_at_lteq = options[:query][:placed_at_lteq]
            paid_at_gteq = options[:query][:paid_at_gteq]
            paid_at_lteq = options[:query][:paid_at_lteq]
            where = options[:where] || 1

            extra_condition = []
            extra_condition << "l.itemable_id in (#{itemable_id_in.join(',')})" if itemable_id_in.present?
            extra_condition << "o.shop_id=#{shop_id_eq}" if shop_id_eq.present?
            extra_condition << "o.branch_id = #{branch_id_eq}" if branch_id_eq.present?
            extra_condition << "o.branch_id in (#{branch_id_in.join(',')})" if branch_id_in.present?
            extra_condition << "o.pay_item_state = '#{pay_item_state_eq}'" if pay_item_state_eq == 'paid'
            extra_condition << "o.pay_item_state in ('none', 'unpaid')" if pay_item_state_eq == 'unpaid'
            extra_condition << "o.paid_at >= '#{to_sql_time(paid_at_gteq)}'" if paid_at_gteq.present?
            extra_condition << "o.paid_at <= '#{to_sql_time(paid_at_lteq)}'" if paid_at_lteq.present?
            extra_condition << where
            extra_condition << "o.placed_at >= '#{to_sql_time(placed_at_gteq)}'" if placed_at_gteq.present?
            extra_condition << "o.placed_at <= '#{to_sql_time(placed_at_lteq)}'" if placed_at_lteq.present?
            sql = <<-SQL
              SELECT
                product_name,
                sum(quantity - subtract_quantity - move_quantity) as quantity,
                sum((quantity - subtract_quantity - move_quantity) * price) as amount,
                sum(l.adjustment_total) + sum(l.apportion_adjustment_total) as adjustment_total,
                sum(l.not_actual_amount) as not_actual_amount,
                category_names,
                sku
              FROM
                  ddt_line_items as l
                      INNER JOIN ddt_orders as o ON o.id = l.order_id
              WHERE
                  o.deleted_at IS NULL
                      AND l.itemable_type = 'Ddt::ComboPackage'
                      AND l.is_subtract = 0
                      AND l.is_moved = 0
                      AND (quantity - subtract_quantity - move_quantity) > 0
                      #{extra_condition.present? ? " AND #{extra_condition.join(' AND ')}" : ""}
              GROUP BY l.#{group};
            SQL
            ActiveRecord::Base.connection.execute(sql).to_a.map do |item|
              {
                product_name:   item[0],
                quantity:       item[1],
                amount:         item[2],
                adjustment_total: (item[3] || 0),
                not_actual_amount: item[4],
                category_names: item[5],
                sku:            item[6]
              }
            end
          end

          def self.combo_sale_list(options={})
            itemable_id_in = options[:query][:itemable_id_in]
            shop_id_eq = options[:query][:shop_id_eq]
            branch_id_in = options[:query][:branch_id_in]
            branch_id_eq = options[:query][:branch_id_eq]
            pay_item_state_eq = (options[:query][:pay_item_state_eq]  || 'paid')
            placed_at_gteq = options[:query][:placed_at_gteq]
            placed_at_lteq = options[:query][:placed_at_lteq]
            paid_at_gteq = options[:query][:paid_at_gteq]
            paid_at_lteq = options[:query][:paid_at_lteq]
            where = options[:where] || 1
            extra_condition = []
            extra_condition << "l.itemable_id in (#{itemable_id_in.join(',')})" if itemable_id_in.present?
            extra_condition << "o.shop_id=#{shop_id_eq}" if shop_id_eq.present?
            extra_condition << "o.branch_id = #{branch_id_eq}" if branch_id_eq.present?
            extra_condition << "o.branch_id in (#{branch_id_in.join(',')})" if branch_id_in.present?
            extra_condition << "o.pay_item_state = '#{pay_item_state_eq}'" if pay_item_state_eq == 'paid'
            extra_condition << "o.pay_item_state in ('none', 'unpaid')" if pay_item_state_eq == 'unpaid'
            extra_condition << "o.paid_at >= '#{to_sql_time(paid_at_gteq)}'" if paid_at_gteq.present?
            extra_condition << "o.paid_at <= '#{to_sql_time(paid_at_lteq)}'" if paid_at_lteq.present?
            extra_condition << where
            extra_condition << "o.placed_at >= '#{to_sql_time(placed_at_gteq)}'" if placed_at_gteq.present?
            extra_condition << "o.placed_at <= '#{to_sql_time(placed_at_lteq)}'" if placed_at_lteq.present?
            sql = <<-SQL
              SELECT
                product_name,
                itemable_name,
                itemable_id,
                quantity - subtract_quantity - move_quantity,
                price,
                (quantity - subtract_quantity - move_quantity) * price
              FROM
                  ddt_line_items as l
                      INNER JOIN ddt_orders as o ON o.id = l.order_id
              WHERE
                  o.deleted_at IS NULL
                      AND o.pay_item_state = 'paid'
                      AND l.itemable_type = 'Ddt::ComboPackage'
                      AND l.is_subtract = 0
                      AND l.is_moved = 0
                      AND (quantity - subtract_quantity - move_quantity) > 0
                      #{extra_condition.present? ? " AND #{extra_condition.join(' AND ')}" : ""}
            SQL
            ActiveRecord::Base.connection.execute(sql).to_a.map do |item|
              {
                product_name:   item[0],
                itemable_name:  item[1],
                itemable_id:    item[2],
                quantity:       item[3],
                price:          item[4],
                amount:         item[5],
              }
            end
          end

          def self.by_weight_product_sale_list(options={})
            itemable_id_in = options[:query][:itemable_id_in]
            sku_in = options[:query][:sku_in]
            order_id_eq = options[:query][:order_id_eq]
            shop_id_eq = options[:query][:shop_id_eq]
            branch_id_in = options[:query][:branch_id_in]
            branch_id_eq = options[:query][:branch_id_eq]
            pay_item_state_eq = (options[:query][:pay_item_state_eq]  || 'paid')
            placed_at_gteq = options[:query][:placed_at_gteq]
            placed_at_gt = options[:query][:placed_at_gt]
            placed_at_lteq = options[:query][:placed_at_lteq]
            placed_at_lt = options[:query][:placed_at_lt]
            paid_at_gteq = options[:query][:paid_at_gteq]
            paid_at_gt = options[:query][:paid_at_gt]
            paid_at_lteq = options[:query][:paid_at_lteq]
            paid_at_lt = options[:query][:paid_at_lt]
            where = options[:where] || 1

            extra_condition = []
            extra_condition << "l.itemable_id in (#{itemable_id_in.join(',')})" if itemable_id_in.present?
            extra_condition << "l.sku in (#{sku_in.map{|i| "'%s'" % i}.join(',')})" if sku_in.present?
            extra_condition << "o.id=#{order_id_eq}" if order_id_eq.present?
            extra_condition << "o.shop_id=#{shop_id_eq}" if shop_id_eq.present?
            extra_condition << "o.branch_id = #{branch_id_eq}" if branch_id_eq.present?
            extra_condition << "o.branch_id in (#{branch_id_in.join(',')})" if branch_id_in.present?
            extra_condition << "o.pay_item_state = '#{pay_item_state_eq}'" if pay_item_state_eq == 'paid'
            extra_condition << "o.pay_item_state in ('none', 'unpaid')" if pay_item_state_eq == 'unpaid'
            extra_condition << "o.paid_at >= '#{to_sql_time(paid_at_gteq)}'" if paid_at_gteq.present?
            extra_condition << "o.paid_at > '#{to_sql_time(paid_at_gt)}'" if paid_at_gt.present?
            extra_condition << "o.paid_at <= '#{to_sql_time(paid_at_lteq)}'" if paid_at_lteq.present?
            extra_condition << "o.paid_at < '#{to_sql_time(paid_at_lt)}'" if paid_at_lt.present?
            extra_condition << where
            extra_condition << "o.placed_at >= '#{to_sql_time(placed_at_gteq)}'" if placed_at_gteq.present?
            extra_condition << "o.placed_at > '#{to_sql_time(placed_at_gt)}'" if placed_at_gt.present?
            extra_condition << "o.placed_at <= '#{to_sql_time(placed_at_lteq)}'" if placed_at_lteq.present?
            extra_condition << "o.placed_at < '#{to_sql_time(placed_at_lt)}'" if placed_at_lt.present?

            sql = <<-SQL
              SELECT
                product_name,
                itemable_name,
                itemable_id,
                unit_name,
                quantity - subtract_quantity - move_quantity,
                price,
                (quantity - subtract_quantity - move_quantity) * price,
                l.adjustment_total + l.apportion_adjustment_total as adjustment_total,
                l.not_actual_amount,
                category_names,
                l.sku
              FROM
                  ddt_line_items as l
                      INNER JOIN ddt_orders as o ON o.id = l.order_id
              WHERE
                  o.deleted_at IS NULL
                      AND l.itemable_type = 'Ddt::VariantPackage'
                      AND l.is_subtract = 0
                      AND (quantity - subtract_quantity - move_quantity) > 0
                      #{extra_condition.present? ? " AND #{extra_condition.join(' AND ')}" : ""};
            SQL
            ActiveRecord::Base.connection.execute(sql).to_a.map do |item|
              {
                product_name:   item[0],
                itemable_name:  item[1],
                itemable_id:    item[2],
                unit_name:      item[3],
                quantity:       item[4],
                price:          item[5],
                amount:         item[6],
                adjustment_total: (item[7] || 0),
                not_actual_amount: item[8],
                category_names: item[9],
                sku:            item[10]
              }
            end
          end

          def self.pay_item_amount(options={})
            shop_id_eq   = options[:query][:shop_id_eq]
            branch_id_in = options[:query][:branch_id_in]
            branch_id_eq = options[:query][:branch_id_eq]
            paid_at_gt = options[:query][:paid_at_gt]
            paid_at_gteq = options[:query][:paid_at_gteq]
            paid_at_lt = options[:query][:paid_at_lt]
            paid_at_lteq = options[:query][:paid_at_lteq]
            pay_method_name_sym_eq = options[:query][:pay_method_name_sym_eq]
            order_type_eq = options[:query][:order_type_eq]
            order_type_in = options[:query][:order_type_in]
            where = options[:where] || 1
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map do |name|
              if group_by_order_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name.to_sym)
                group_by_time_type_to_sql_simple(name, table_name: :p)
              end
            end.compact.first(2)

            select_group_columns = []
            select_group_columns << (group_by_names.map(&:to_sym).include?(:paid_at) ? 'p.paid_at' : 'any_value(p.paid_at)')
            select_group_columns << (group_by_names.map(&:to_sym).include?(:branch_id) ? 'p.branch_id' : 'any_value(p.branch_id)')
            select_group_column_str = select_group_columns.join(',')

            extra_condition = []
            extra_condition << "p.shop_id = #{shop_id_eq}" if shop_id_eq.present?
            extra_condition << "p.branch_id = #{branch_id_eq}" if branch_id_eq.present?
            extra_condition << "p.branch_id in (#{branch_id_in.join(',')})" if branch_id_in.present?
            extra_condition << "p.paid_at >= '#{to_sql_time(paid_at_gteq)}'" if paid_at_gteq.present?
            extra_condition << "p.paid_at > '#{to_sql_time(paid_at_gt)}'" if paid_at_gt.present?
            extra_condition << "p.paid_at <= '#{to_sql_time(paid_at_lteq)}'" if paid_at_lteq.present?
            extra_condition << "p.paid_at < '#{to_sql_time(paid_at_lt)}'" if paid_at_lt.present?
            extra_condition << "p.pay_method_name_sym = '#{pay_method_name_sym_eq}'" if pay_method_name_sym_eq.present?
            extra_condition << "o.type = '#{order_type_eq}'" if order_type_eq.present?
            extra_condition << "o.type in ('#{order_type_in.join('\',\'')}')" if order_type_in.present?
            extra_condition << where
            sql = <<-SQL
              SELECT
                p.pay_method_id,
                any_value(p.pay_method_name),
                any_value(p.pay_method_name_sym),
                any_value(p.pay_method_code),
                any_value(p.pay_method_percent_of_actual),
                any_value(p.pay_method_builtin),
                sum(p.amount),
                count(*),
                #{select_group_column_str}
              FROM
                  ddt_pay_items as p
                      INNER JOIN ddt_orders as o ON o.id = p.order_id
              WHERE
                  p.state = 'paid' and o.pay_item_state = 'paid'
              AND p.deleted_at IS NULL
                    #{extra_condition.present? ? " AND #{extra_condition.join(' AND ')}" : ""}
              group by p.pay_method_id
                #{group_by_columns.present? ? " , #{group_by_columns.join(',')}" : ""}
              ;
            SQL
            ActiveRecord::Base.connection.execute(sql).to_a.map do |item|
              {
                pay_method_id:        item[0],
                pay_method_name:      item[1],
                pay_method_name_sym:  item[2],
                pay_method_code:      item[3],
                pay_method_percent_of_actual: item[4],
                pay_method_builtin:   item[5] == 1 ? true : false,
                amount:               item[6],
                count:                item[7],
                paid_at:              item[8],
                branch_id:            item[9]
              }
            end
          end

          def self.pay_item_list(options={} )
            result = Model::PayItem.includes(:order).order('ddt_pay_items.paid_at desc').ransack(options[:query]).result
            if options[:page].present?
              result = result.paginate(page: options[:page])
            end
            result.map do |item|
              if item.order.present?
                {
                  branch_id:            item.branch_id,
                  order_id:             item.order_id,
                  order_number:         item.order.number,
                  order_type:           item.order.type,
                  table_name:           item.order.table_name,
                  table_zone_name:      item.order.table_zone_name,
                  guest_num:            item.order.guest_num || 1,
                  per_consume:          (item.amount/(item.order.guest_num || 1) ).round(2),
                  pay_method_id:        item.pay_method_id,
                  pay_method_name:      item.pay_method_name,
                  pay_method_name_sym:  item.pay_method_name_sym,
                  pay_method_code:      item.pay_method_code,
                  pay_method_percent_of_actual: item.pay_method_percent_of_actual,
                  pay_method_builtin:   item.pay_method_builtin,
                  amount:               item.amount,
                  placed_at:            (item.order.placed_at.strftime("%F %T") rescue nil),
                  paid_at:              item.paid_at.strftime("%F %T"),
                  last_time:            (item.paid_at - item.order.placed_at rescue nil),
                  settle_account_id:    (item.order.settle_account_id)
                }
              else
                nil
              end
            end.compact
          end

          def self.pay_item_not_actual_amount(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_pay_item_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              result = Model::PayItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid })
                            .reorder("sum(ddt_pay_items.amount * (100 - ddt_pay_items.pay_method_percent_of_actual) / 100) desc")
                            .ransack(query_params).result.sum("ddt_pay_items.amount * (100 - ddt_pay_items.pay_method_percent_of_actual) / 100")
            else
              result = Model::PayItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid })
                            .reorder("sum(ddt_pay_items.amount * (100 - ddt_pay_items.pay_method_percent_of_actual) / 100) desc")
                            .group(group_by_columns)
                            .ransack(query_params).result.sum("ddt_pay_items.amount * (100 - ddt_pay_items.pay_method_percent_of_actual) / 100")
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.pay_item_actual_amount(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_pay_item_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              result = Model::PayItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid })
                            .reorder("sum(ddt_pay_items.amount * ddt_pay_items.pay_method_percent_of_actual / 100) desc")
                            .ransack(query_params).result.sum("ddt_pay_items.amount * ddt_pay_items.pay_method_percent_of_actual / 100")
            else
              result = Model::PayItem.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid })
                            .reorder("sum(ddt_pay_items.amount * ddt_pay_items.pay_method_percent_of_actual / 100) desc")
                            .group(group_by_columns)
                            .ransack(query_params).result.sum("ddt_pay_items.amount * ddt_pay_items.pay_method_percent_of_actual / 100")
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.guest_num_count(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_order_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name.to_sym)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              Model::Order.where(type: "Ddt::EatInHallOrder").ransack(query_params).result.sum(:guest_num)
            else
              result = Model::Order.where(type: "Ddt::EatInHallOrder").group(group_by_columns).ransack(query_params).result.sum(:guest_num)
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.adjustment_amount(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_adjustment_columns.include?(name)
                name
              elsif group_by_time_types(:paid_at).include?(name)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              result = Model::Adjustment.root.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, disabled: false)
                            .ransack(query_params).result.sum("amount")
            else
              result = Model::Adjustment.root.includes(:order).references(:ddt_orders)
                            .where(ddt_orders: { pay_item_state: :paid }, disabled: false)
                            .group(group_by_columns)
                            .ransack(query_params).result.sum("amount")
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          def self.adjustment_list(options={})
            query = options[:query]
            adjustments = Ddt::OrderService::Api::Mock::Model::Adjustment.root.ransack(query).result
            if options[:page].present?
              adjustments = adjustments.paginate(page: options[:page])
            end
            adjustments.map do |adjustment|
              {
                order_id: adjustment.order_id,
                reason: adjustment.reason,
                amount: adjustment.amount,
                created_at: adjustment.created_at.strftime('%F %T'),
                operator_id: adjustment.operator_id,
                authorizer_id: adjustment.authorizer_id,
                label: adjustment.label,
              }
            end
          end

          def self.order_change_list(options={})
            query_params = options[:query]
            logs = Model::OrderChangeLog.includes(:order).references(:ddt_orders).ransack(query_params).result
            if options[:page].present?
              logs = logs.paginate(page: options[:page])
            end
            logs.map do |log|
              {
                type: log.type,
                description: log.description,
                created_at: log.created_at,
                operator_name: log.operator_name,
                order_id: log.order.try(:id),
                order_number: log.order.try(:number),
                order_type: log.order.try(:type),
                order_total: log.order.try(:total),
                order_table_name: log.order.try(:table_name),
                order_table_zone_name: log.order.try(:table_zone_name)
              }
            end
          end

          def self.order_change_count(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by]).flatten
            select_columns = 'count(*) as times'
            group_by_columns = group_by_names.map(&:to_sym).map{|name|
              if group_by_time_types(:created_at).include?(name.to_sym)
                group_by_time_type_to_sql_simple(name, table_name: :ddt_order_change_logs)
              else
                name
              end
            }.compact.first(2)
            select_by_columns = group_by_names.map(&:to_sym).map{|name|
              if group_by_time_types(:created_at).include?(name.to_sym)
                select_by_time_type_to_sql_simple(name, table_name: :ddt_order_change_logs)
              else
                name
              end
            }
            Model::OrderChangeLog.select(select_columns + ", "+select_by_columns.join(",")).group(group_by_columns).ransack(query_params).result
          end

          def self.order_discount_list(options={})
            query_params = options[:query]
            adjustments = Model::Adjustment.root.includes(:order).references(:ddt_orders).where(ddt_orders: {pay_item_state: :paid}, reason: Ddt::OrderService::Adjustment.discount_reasons, disabled: false).ransack(query_params).result
            adjustments.map do |adjustment|
              {
                reason: adjustment.reason,
                label: adjustment.label,
                amount: adjustment.amount,
                created_at: adjustment.created_at,
                operator_id: adjustment.operator_id,
                authorizer_id: adjustment.authorizer_id,
                order_number: (adjustment.order.number rescue ''),
                order_table_name: (adjustment.order.table_name rescue ''),
                order_table_zone_name: (adjustment.order.table_zone_name rescue ''),
              }
            end
          end

          def self.guest_num(options={})
            query_params = options[:query]
            group_by_names = Array(options[:group_by]).flatten
            group_by_columns = group_by_names.map(&:to_sym).map {|name|
              if group_by_order_columns.include?(name)
                name
              elsif group_by_time_types(:placed_at).include?(name.to_sym)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              elsif group_by_time_types(:paid_at).include?(name.to_sym)
                group_by_time_type_to_sql(name, table_name: :ddt_orders)
              end
            }.compact.first(2)
            if group_by_columns.count == 0
              Model::Order.where(type: "Ddt::EatInHallOrder", pay_item_state: :paid).ransack(query_params).result.sum(:guest_num)
            else
              result = Model::Order.where(type: "Ddt::EatInHallOrder", pay_item_state: :paid).group(group_by_columns).ransack(query_params).result.sum(:guest_num)
              exchange_result_by_group_column_count(result, group_by_columns.count)
            end
          end

          private
          def self.group_by_order_columns
            [:shop_id,  :branch_id, :waiter_id, :vip_info_id, :type, :state, :table_id, :table_name, :table_zone_name, :track_from, :settle_account_id, :pay_method]
          end

          def self.group_by_line_item_columns
            [:itemable_id, :itemable_name, :product_name, :category_names]
          end

          def self.group_by_pay_item_columns
            [:pay_method_id]
          end

          def self.group_by_adjustment_columns
            [:reason, :source_id, :source_type, :"ddt_adjustments.branch_id"]
          end

          def self.group_by_time_types(time_column)
            [:hour, :day, :week, :month, :year].map{|key| "#{time_column}_#{key}".to_sym }
          end

          def self.group_by_time_type_to_sql(time_type, table_name: :ddt_orders)
            time_column = time_type.to_s.split("_")[0..-2].join("_")
            type = time_type.to_s.split("_")[-1]
            case type.to_sym
            when :day
              "TO_CHAR(#{table_name}.#{time_column}, 'MM-DD')"
            when :month
              "TO_CHAR(#{table_name}.#{time_column}, 'YYYY-MM')"
            when :year
              "TO_CHAR(#{table_name}.#{time_column}, 'YYYY')"
            end
          end

          def self.group_by_time_type_to_sql_simple(time_type, table_name: :ddt_orders)
            time_column = time_type.to_s.split("_")[0..-2].join("_")
            type = time_type.to_s.split("_")[-1]
            case type.to_sym
            when :hour
              "TO_CHAR(#{table_name}.#{time_column}, 'HH24')"
            when :day
              "TO_CHAR(#{table_name}.#{time_column}, 'DD')"
            when :week
              "TO_CHAR(#{table_name}.#{time_column}, 'D')"
            when :month
              "TO_CHAR(#{table_name}.#{time_column}, 'DD')"
            when :year
              "TO_CHAR(#{table_name}.#{time_column}, 'MM')"
            end
          end

          def self.select_by_time_type_to_sql_simple(time_type, table_name: :ddt_orders)
            time_column = time_type.to_s.split("_")[0..-2].join("_")
            type = time_type.to_s.split("_")[-1]
            case type.to_sym
            when :hour
              "TO_CHAR(#{table_name}.#{time_column}, 'HH24') as time"
            when :day
              "TO_CHAR(#{table_name}.#{time_column}, 'DD') as time"
            when :week
              "TO_CHAR(#{table_name}.#{time_column}, 'D') as time"
            when :month
              "TO_CHAR(#{table_name}.#{time_column}, 'DD') as time"
            when :year
              "TO_CHAR(#{table_name}.#{time_column}, 'MM') as time"
            end
          end

          def self.exchange_result_by_group_column_count(result, group_column_count)
            case group_column_count
            when 1
              result.symbolize_keys
            when 2
              result.group_by{|k,_| k[0]}.map{|k, a| [k, a.inject({}){|h, v| h[v[0][1]] = v[1]; h}] }.to_h.deep_symbolize_keys
            end
          end

          def self.to_sql_time(time)
            (time.is_a? String) ? time : time.strftime('%F %T')
          end

        end
      end
    end
  end
end
