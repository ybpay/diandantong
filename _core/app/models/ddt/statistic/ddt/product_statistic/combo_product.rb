#encoding: utf-8
module Ddt
  module ProductStatistic
    class ComboProduct < ::Ddt::ProductStatistic::Base
      attr_accessor :group_by_combo, :group_by, :filters, :pay_item_state, :order_id
      hash_attrs({
          按套餐: :group_by_combo,
          分组方式: :group_by,
          过滤: :filters,
          支付状态: :pay_item_state
     })

      def initialize(options={})
        super
        @group_by_combo = ('1' == options[:group_by_combo]) ? true : false
        @group_by = options[:group_by] || :sku
        @filters  = options[:filters] || []
        @pay_item_state = options[:pay_item_state] || :paid
        @order_id = options[:order_id]
      end

      def self.class_info
        {
          name: 'combo_product',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id, :group_by_combo],
          default_params: today,
          label: '套餐产品',
          sortable: true,
          expose_to_api: true
        }
      end

      def result
        query = { shop_id_eq: shop.id}
        return [] if branch_id.blank?
        if [:paid, :unpaid].include? pay_item_state.to_sym
          query[:order_pay_item_state_eq] = pay_item_state if pay_item_state.to_sym == :paid
          query[:order_pay_item_state_in] = [:none, :unpaid] if pay_item_state.to_sym == :unpaid
        end
        query[:order_id_eq] = order_id if order_id.present?
        query[:branch_id_eq] = branch_id if one_branch?

        # query[pay_item_state.to_sym == :paid ? :order_paid_at_gteq : :order_placed_at_gteq] = start_time
        # query[pay_item_state.to_sym == :paid ? :order_paid_at_lteq : :order_placed_at_lteq] = end_time
        # result = Ddt::OrderService::Api::Statistic.combo_item_list(where: where, query: query)

        unless @items.present?
          params = {where: time_interval_clause, query: query}
          split_query_name = pay_item_state.to_sym == :paid ? 'order_paid_at' : 'order_placed_at'

          @items = split_query_by_time(
              start_time: start_time,
              end_time: end_time,
              identity_keys: [:product_name, :itemable_id, :itemable_name, :original_price, :price],
              accumulate_keys: [:quantity, :adjustment_total, :not_actual_amount]
          ) do |current_date, next_date, has_next|
            query[(split_query_name + '_gteq').to_sym] = current_date
            if has_next
              query[(split_query_name + '_lt').to_sym] = next_date
            else
              query.delete((split_query_name + '_lt').to_sym)
              query[(split_query_name + '_lteq').to_sym] = next_date
            end
            Ddt::OrderService::Api::Statistic.combo_item_list(params)
          end
        end
        @items.present? ? parse_names(@items) : []
      end
      cache_result

      def filters
        [
          filter_branch(support_all: false),
          {name: 'group_by_combo', type: 'collection', collection: [['分组', '1'], ['不分组', '0']], prompt: '按套餐分组', include_blank: false},
          filter_start_time,
          filter_end_time,
          filter_time_interval
        ]
      end

      def title
        if group_by_combo
          %W[套餐名 产品名 平均售价 销售数量 销售金额 折扣 非实收 数量占比 金额占比]
        else
          %W[产品名 平均售价 销售数量 销售金额 折扣 非实收 数量占比 金额占比]
        end
      end

      def body
        items = result
        return [] if items.blank?
        content = []
        items.each do |item|
          item.delete(:itemable_id)
          item.delete(:sku)
          item.delete(:category_names)
          content << item.values
        end
        content
      end

      def foot
        items = result
        quantity = sum(items, :quantity)
        amount = sum(items, :amount)
        discount = sum(items, :adjustment_total)
        not_actual_amount = sum(items, :not_actual_amount)
        if group_by_combo
          [['合计', '-', '-', quantity, amount, discount, not_actual_amount, '-', '-']]
        else
          [['合计', '-', quantity, amount, discount, not_actual_amount, '-', '-']]
        end
      end

      def to_variant_sales
        items = result
        items.map do |item|
          {
            sku: item[:sku],
            type: :combo_product,
            name:  item[:product_name],
            category_names: item[:category_names],
            quantity: item[:quantity],
            adjustment_total: item[:adjustment_total],
            not_actual_amount: item[:not_actual_amount],
            amount:   item[:amount].round(2)
          }.to_obj
        end
      end

      def parse_names(items)
        items = items.map(&:to_obj)
        result = []
        unless items.blank?
          package_ids = items.map(&:itemable_id)
          group = []
          if group_by_combo
            group << 'cpi.combo_id'
            group << 'sku'
            group << 'variant_id'
          else
            group << (group_by.to_sym == :itemable_id ? 'variant_id' : 'sku')
          end
          query = {combo_package_id: package_ids}


          append_query = nil
          if @filters.present? && [:itemable_id, :sku].include?(group_by)
            case group_by.to_sym
            when :sku
              append_query = " sku IN (#{@filters.map{|i| "'%s'" % i}.join(',')})"
            when :itemable_id
              append_query = " variant_id IN (#{@filters.join(',')})"
            end
          end

          hash = items.sort{|a, b| b.quantity - a.quantity}.group_by(&:quantity)


          if hash.length == 1
            line_item_quantity = hash.keys[0]
          else
            line_item_quantity = ' (CASE cpi.combo_package_id'
            hash.each do |quantity, items|
              if quantity > 1
                items.each do |i|
                  line_item_quantity << " WHEN #{i.itemable_id} THEN #{quantity}"
                end
              else
                line_item_quantity << ' ELSE 1 '
              end
            end
            line_item_quantity << ' END) '
          end

          sql = " SELECT sku, cpi.combo_id, variant_id, SUM(quantity * #{line_item_quantity}) AS quantity, SUM(price * #{line_item_quantity}) AS amount, SUM(adjustment_total + apportion_adjustment_total) as adjustment_total, SUM(not_actual_amount) as not_actual_amount "
          sql << ' FROM ddt_combo_package_items AS cpi'
          sql << ' INNER JOIN ddt_combo_packages AS cp ON cp.id = cpi.combo_package_id'
          sql << " WHERE cp.id IN (#{package_ids.map { |id| ActiveRecord::Base.connection.quote(id) }.join(',')}) #{(append_query.nil? ? '' : ' AND ' + append_query)}"
          sql << " GROUP BY #{group.join(',')}"
          cpitems = Ddt::ComboPackageItem.find_by_sql(sql)

          variants = get_variants(cpitems.map(&:variant_id))
          cpitems.each do |item|
            variant = variants.detect{|v| v.id == item.variant_id}
            product_name = variant.name_with_options_text
            if group_by_combo
              combo_name = get_combo_name(items, item.combo_id)
              result << {combo_name: combo_name, product_name: product_name, avg_price: (item.amount / item.quantity).round(2),  quantity: item.quantity, amount: item.amount, adjustment_total: item.adjustment_total, not_actual_amount: item.not_actual_amount}
            else
              result << {itemable_id: item.variant_id, sku: item.sku, product_name: product_name, category_names: variant.category_names, avg_price: (item.amount / item.quantity).round(2), quantity: item.quantity, amount: item.amount, adjustment_total: item.adjustment_total, not_actual_amount: item.not_actual_amount}
            end
          end
          total_quantity = sum(result, :quantity)
          total_amount   = sum(result, :amount)
          result.each do |obj|
            obj[:quantity_rate] = rate_label(obj[:quantity], total_quantity)
            obj[:amount_rate] = rate_label(obj[:amount], total_amount)
          end
        end
        result
      end

      def get_variants(variant_ids)
        @variants ||= Ddt::Variant.with_discarded.where(id: variant_ids.uniq)
      end

      def get_combo_name(items, combo_id)
        package_ids = items.map{|i| i[:itemable_id]}
        @h ||= {}
        if @h[combo_id].present?
          @h[combo_id]
        else
          package = Ddt::ComboPackage.where(id: package_ids, combo_id: combo_id).first
          item = items.detect{|i| i[:itemable_id] == package.id}
          name = item[:itemable_name].split('[')[0]
          @h[combo_id] = name
        end
      end

    end
  end
end
