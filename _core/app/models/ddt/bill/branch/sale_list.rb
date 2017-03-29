module Ddt
  module Bill
    module Branch
      class SaleList < ::Ddt::Bill::Branch::Base
        attr_accessor :variant_ids, :time_interval_id, :pay_item_state, :params

        def initialize(branch, params)
          super
          @params = params
          @skus = set_skus(params)
          @pay_item_state = (params[:pay_item_state] || 'paid')
        end

        def variant_items
          return [] if @params[:category_ids].present? && @skus.blank?
          @variant_items ||= Ddt::ProductStatistic::VariantSummary.new(
            group_by: :sku,
            filters: @skus,
            shop: shop,
            branch_id:@branch.id,
            start_time: @start_time,
            end_time: @end_time,
            pay_item_state: @pay_item_state,
            time_interval_id: @time_interval_id,
            is_async: false
          ).to_variant_sales
        end

        def variant_package_items
          return [] if @params[:category_ids].present? && @skus.blank?
          @variant_package_items ||= Ddt::ProductStatistic::VariantPackageSummary.new(
            group_by: :sku,
            filters: @skus,
            shop: shop,
            branch_id: @branch.id,
            start_time: @start_time,
            end_time: @end_time,
            pay_item_state: @pay_item_state,
            time_interval_id: @time_interval_id,
            is_async: false
          ).to_variant_sales
        end

        def combo_items
          return [] if @params[:category_ids].present? && @skus.blank?
          @combo_items ||= Ddt::ProductStatistic::ComboProduct.new(
            group_by: :sku,
            filters: @skus,
            shop: shop,
            branch_id: @branch.id,
            start_time: @start_time,
            end_time: @end_time,
            pay_item_state: @pay_item_state,
            time_interval_id: @time_interval_id,
            is_async: false
          ).to_variant_sales
        end

        def all_items
          @all_items ||= (variant_items + combo_items + variant_package_items).group_by(&:sku).map do |sku, items|
            item = items[0]
            SaleList::Item.new(
              category_names: item.category_names,
              name: item.name,
              quantity: items.map(&:quantity).sum,
              amount: items.map(&:amount).sum,
              adjustment_total: items.map(&:adjustment_total).sum,
              not_actual_amount: items.map(&:not_actual_amount).sum
            )
          end
        end

        def group_items
          @group_items ||= all_items.map{|item| item.calculate_percent(total_amount); item}.group_by(&:group_name)
        end

        def total_amount
          @total_amount ||= all_items.map(&:amount).sum.round(2)
        end

        def total_adjustment
          @total_adjustment ||= all_items.map(&:adjustment_total).sum
        end

        def total_not_actual_amount
          @total_not_actual_amount ||= all_items.map(&:not_actual_amount).sum
        end

        def total_quantity
          @total_quantity ||= all_items.map(&:quantity).sum
        end

        def moling_amount
          return 0 if time_interval_id.present?
          return 0 if @pay_item_state != 'paid'
          return 0 if @skus.present?
          @moling_amount ||= Ddt::OrderService::Api::Statistic.order_moling_amount({
            query: {
              branch_id_eq: @branch.id,
              pay_item_state: 'paid',
              paid_at_gteq: @start_time,
              paid_at_lteq: @end_time,
            }
          })
        end

        def content
          lines = []
          lines << "销售报表"
          lines << "门店: #{@branch.name}"
          lines << "时间: #{@start_time}"
          lines << "  至: #{@end_time}"
          lines << "(以订单支付时间计算)"
          group_items.each do |group_name, items|
            lines << "[#{group_name}]"
            lines << '%-18s  %2s  %6s  %3s' % %w(项目 数量 金额 金额%)
            lines << '-' * 44
            items.each do |item|
              lines << '%s  %4d  %8.2f  %5.2f%%' % [item.name.fixed_width(20), item.quantity, item.amount, item.percent * 100]
            end
            lines << '-' * 44
            lines << '%-18s  %4d  %8.2f  %5.2f%%' % ['合计', items.map(&:quantity).sum, items.map(&:amount).sum, items.map(&:percent).sum * 100]
            lines << ''
          end

          lines << '-' * 44
          lines << '%-18s  %4d  %8.2f' % ['总数', total_quantity, total_amount]
          lines << '%-18s  %-4s  %8.2f' % ['抹零', '', moling_amount] if moling_amount > 0
          lines << '=' * 44

          lines << "读取人员: #{@operator.name}"
          lines << "读取时间: #{Time.now}"

          lines.join("\n")
          # "<pre>#{lines.join("\n")}</pre>"
        end

        class Item
          attr_accessor :name, :category_names, :quantity, :adjustment_total, :not_actual_amount, :amount, :percent
          def initialize(params={})
            params.each do |key, value|
              self.send("#{key}=", value)
            end
          end

          def group_name
            category_names
          end

          def calculate_percent(total_amount)
            @percent = total_amount > 0 ? (amount / total_amount).round(4) : 0
          end
        end

        private
        def set_skus(params)
          category_ids = params[:category_ids]
          variant_ids = params[:variant_ids]
          skus = []

          if category_ids.present?
            category_ids = category_ids.split(',').map(&:to_i)
            sub_category_ids = Ddt::Category.select(:id).where(parent_id: category_ids).map(&:id)
            all_category_ids = (category_ids + sub_category_ids).uniq
            products_ids = Ddt::Category.find_by_sql("
              SELECT product_id FROM ddt_categories_products WHERE category_id in (#{all_category_ids.join(',')})
              ").map(&:product_id)
            skus.concat(Ddt::Variant.where(product_id: products_ids).pluck(:sku))
          end

          if variant_ids.present?
            skus.concat(Ddt::Variant.where(id: variant_ids.split(',').map(&:to_i)).pluck(:sku))
          end

          skus.uniq!
          skus
        end
      end
    end
  end
end
