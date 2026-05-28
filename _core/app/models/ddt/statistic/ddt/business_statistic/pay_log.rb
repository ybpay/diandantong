# encoding: utf-8
module Ddt
  module BusinessStatistic
    class PayLog < ::Ddt::BusinessStatistic::Base
      attr_accessor :pay_methods, :order_number, :date, :settle_account_id
      include Ddt::CacheModel
      cache_model 'Ddt::Account', with_discarded: true
      hash_attrs({
        日期: :date,
        订单号: :order_number,
        支付方式: :pay_methods,
        收银员: :settle_account_id
     })

      def self.class_info
        {
          name: 'pay_log',
          permit_params: [:date, :order_number, :pay_methods],
          label: '结算明细',
          render_view: true # 渲染自己的html模板
        }
      end

      def initialize(options={})
        super
        @date = (Date.parse(options[:date]) rescue nil)
        if @date.present?
          @start_time = @date.beginning_of_day
          @end_time = @date.end_of_day
        end
        if options[:order_number].present?
          @order_number = options[:order_number]
          @start_time = nil
          @end_time = nil
          @priority_queue = PRIORITY_QUEUE_STATISTICS
        end
        @pay_methods = options[:pay_methods] if options[:pay_methods].present?
        @settle_account_id = options[:settle_account_id] if options[:settle_account_id].present?
      end

      def result
        pay_method_arr = pay_methods.blank? ? [] : pay_methods.split(',')
        # items = Ddt::OrderService::Api::Statistic.pay_item_list(
        #   query: {
        #     branch_id_eq: branch_id,
        #     shop_id_eq: shop.id,
        #     paid_at_gteq: start_time,
        #     paid_at_lteq: end_time,
        #     order_number_eq: order_number,
        #     order_settle_account_id_eq: settle_account_id,
        #     pay_method_name_in: pay_method_arr
        #   },
        # )
        query = {
            shop_id_eq: shop.id,
            branch_id_eq: branch_id,
            order_number_eq: order_number,
            order_settle_account_id_eq: settle_account_id,
            pay_method_name_in: pay_method_arr
        }

        if order_number.present?
          @items ||= Ddt::OrderService::Api::Statistic.pay_item_list({query: query})
        else
          @items ||= split_query_by_time(
              start_time: start_time,
              end_time: end_time,
              concat: true
          ) do |current_date, next_date, has_next|
            if has_next
              q = query.merge(paid_at_gteq: current_date, paid_at_lt: next_date)
            else
              q = query.merge(paid_at_gteq: current_date, paid_at_lteq: next_date)
            end
            Ddt::OrderService::Api::Statistic.pay_item_list({query: q})
          end
        end
      end

      cache_result do |result|
        @items ||= result.present? ? result : []
      end

      def to_csv(file = StringIO.new)
        items = self.result
        account_ids = items.map{|item|item[:settle_account_id]}
        account_id_name_hash = {}
        Ddt::Account.where(id: account_ids).select(:id, :name).find_each do |pair|
          account_id_name_hash[pair.id] = pair.name
        end

        csv = CSV.new(file)
        csv << %W(订单 门店 订单类型 桌台 桌台类型 下单时间 结算时间 持续时间 支付方式 支付金额 人数 人均 结算员)
        items.each do |item|
          csv_line = []
          csv_line << item[:order_number]
          csv_line << get_branch_name(item[:branch_id])
          csv_line << order_type_name(item[:order_type])
          csv_line << item[:table_name]
          csv_line << item[:table_zone_name]
          csv_line << item[:placed_at]
          csv_line << item[:paid_at]
          csv_line << item[:last_time]
          csv_line << item[:pay_method_name]
          csv_line << item[:amount]
          csv_line << item[:guest_num]
          csv_line << item[:per_consume]
          csv_line << (account_id_name_hash[item[:settle_account_id]] rescue '-')
          csv << csv_line
        end
        file
      end

      def order_type_name(order_type)
        case order_type
        when 'Ddt::EatInHallOrder' then '堂点'
        when 'Ddt::FastfoodOrder' then '快餐'
        when 'Ddt::DeliveryOrder' then '外卖'
        when 'Ddt::PaymentOrder' then '买单'
        else
          '其他'
        end
      end

    end
  end
end
