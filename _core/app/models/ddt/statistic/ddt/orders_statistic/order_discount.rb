#encoding: utf-8
module Ddt
  module OrdersStatistic
    class OrderDiscount < OrdersStatistic::Base
      include Ddt::CacheModel
      cache_model 'Ddt::Account', with_deleted: true
      attr_accessor :orders, :order_number, :discount_reason, :records
      hash_attrs({
          订单号: :order_number,
          拆扣原因: :discount_reason
     })

      def self.class_info
        {
          name: 'order_discount',
          permit_params: [:branch_id, :discount_reason, :order_number, :start_time, :end_time],
          label: '订单折扣'
        }
      end

      def initialize(options={})
        super
        @order_number = options[:order_number]
        @discount_reason = options[:discount_reason]
        @discount_reason = nil if @discount_reason.blank?
      end

      def result
        # return @result_hash if @result_hash.present?
        # @orders ||= Ddt::OrderService::Api::Statistic.orders(query: {
        #     shop_id_eq: shop.id,
        #     branch_id_eq: branch_id,
        #     paid_at_gteq: start_time,
        #     paid_at_lteq: end_time,
        #     number_eq: order_number
        #   }
        # ).map(&:to_obj)
        return @result_hash if @result_hash.present?

        params = {
            query: {
                shop_id_eq: shop.id,
                branch_id_eq: branch_id,
                number_eq: order_number
            }
        }
        query = params[:query]

        if @discount_reason.present?
          reasons = [@discount_reason]
        else
          reasons = reason_hash.keys
        end

        part_results = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            concat: true
        ) do |current_date, next_date, has_next|
          query[:paid_at_gteq] = current_date
          if (has_next)
            query[:paid_at_lt] = next_date
          else
            query.delete(:paid_at_lt)
            query[:paid_at_lteq] = next_date
          end

          # id: o.id,
          # number: o.number,
          # total: o.total
          part_orders = Ddt::OrderService::Api::Statistic.orders(params)
          if part_orders.present?
            part_records ||= Ddt::OrderService::Api::Statistic.adjustment_list(
              query: {
                shop_id_eq: shop.id,
                order_id_in: part_orders.map{|order| order[:id] },
                reason_in: reasons,
                disabled: false
              }
            )

            {
                orders: part_orders,
                records: part_records
            }
          else
            nil
          end
        end

        @result_hash = part_results.inject({
            orders: [],
            records: []
        }) do |hash, part|
          hash[:orders].concat(part[:orders])
          hash[:records].concat(part[:records])
          hash
        end

        @orders = @result_hash[:orders]
        @records = @result_hash[:records]
        @result_hash
      end

      cache_result

      def reason_hash
        {
          privilege_discount: '权限打折',
          privilege_reduction: '权限减免',
          privilege_free: '权限免单',
          coupon: '优惠券折扣',
          voucher: '代金券折扣',
          promotion: '促销折扣',
          vip_discount: '会员折扣',
          discount_plan: '折扣方案'
        }
      end

      def reason_collection
        reason_hash.map{|k, v| [v, k]}
      end

      def get_order(order_id)
        return '' if @orders.blank?
        order = @orders.detect{|o| o[:id] == order_id}
        return order
      end

      def filters
        [
          filter_branch(support_all: false),
          {name: 'order_number', type: 'string', placeholder: '订单号'},
          {name: 'discount_reason', type: 'collection', collection: reason_collection, prompt: '折扣类型', include_blank: true},
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %w[订单号 折扣类型 折扣详情 订单金额 折扣金额 打折时间 操作人 权限人]
      end

      def body
        content = []
        r =result
        @orders  = r[:orders]
        @records = r[:records]
        @records.each do |item|
          order = get_order(item[:order_id])
          operator = get_account(item[:operator_id])
          authorizer = get_account(item[:authorizer_id])
          operator_name = operator.blank? ? '未记录' : operator.name
          authorizer_name = authorizer.blank? ? '未记录' : authorizer.name
          content << [
            order.try(:number),
            reason_hash[item[:reason].to_sym],
            item[:label],
            order.try(:total),
            -item[:amount],
            item[:created_at],
            operator_name,
            authorizer_name
          ]
        end
        content
      end

      def link_template
        {
          0 => order_link_template
        }
      end

      def link_hash
        r  = result
        @orders = r[:orders]
        @records= r[:records]
        order_links = @records.map do |item|
          order = get_order(item[:order_id])
          {order_number: order.try(:number), order_id: item[:order_id]}
        end
        order_number_id_hash(order_links)
      end


    end
  end
end
