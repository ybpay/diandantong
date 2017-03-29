# encoding:utf-8
module Ddt
  module OrdersStatistic
    class OrderOrigin < OrdersStatistic::Base

      def self.class_info
        {
          name: 'order_origin',
          paginate: false,
          permit_params: [:branch_id, :start_time, :end_time],
          default_params: today,
          label: '订单来源',
          expose_to_api: true
        }
      end

      def result
        # return [] if branch_id.blank?
        # @items ||= Ddt::OrderService::Api::Statistic.order_times_total(
        #   query: {
        #     shop_id_eq: shop.id,
        #     branch_id_eq: branch_id,
        #     paid_at_gteq: start_time,
        #     paid_at_lteq: end_time
        #   },
        #   group_by: [:track_from, :type]
        # )

        return [] if branch_id.blank?
        params = {
            query: {
                shop_id_eq: shop.id,
                branch_id_eq: branch_id
            },
            group_by: [:track_from, :type]
        }
        query = params[:query]

        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:track_from, :type],
            accumulate_keys: [:adjustment_total, :total, :guest_num, :times]
        ) do |current_date, next_date, has_next|
          query[:paid_at_gteq] = current_date
          if (has_next)
            query[:paid_at_lt] = next_date
          else
            query.delete(:paid_at_lt)
            query[:paid_at_lteq] = next_date
          end
          Ddt::OrderService::Api::Statistic.order_times_total(params).map{|line_item|
            {
              times:                  line_item.times,
              total:                  line_item.total,
              adjustment_total:       line_item.adjustment_total,
              guest_num:              line_item.guest_num,
              track_from:             line_item.track_from,
              type:                   line_item.type
            }
          }
        end
      end

      cache_result

      def origin_collection
        {
          track_froms: %W[FromWebpos FromWechat FromApp],
          track_from_names: %W[收银端 微信 App],
          types: %W[Ddt::EatInHallOrder Ddt::DeliveryOrder Ddt::ReservationOrder Ddt::FastfoodOrder Ddt::GrouponOrder Ddt::PaymentOrder],
          type_names: %W[堂点 外卖 预订 快餐 团购 买单]
        }
      end

      def filters
        [
          filter_branch(support_all: false),
          filter_start_time,
          filter_end_time
        ]
      end

      def custom_thead?
        true
      end

      def custom_thead
        thead = []
        tmp = [{name: '', th_attrs: {}}]
        tr = tmp.dup
        tr2= tmp.dup
        origin_collection[:type_names].each do |type|
          tr << {name: type, th_attrs: {colspan: '2'}}
          tr2<< {name: '订单数', th_attrs: {}}
          tr2<< {name: '订单总额', th_attrs: {}}
        end
        thead << tr
        thead << tr2
      end

      def title
        origin_collection[:type_names].map{|type_name| ["#{type_name}订单数", "#{type_name}订单总价"]}.flatten.unshift("")
      end

      def body
        items = result
        content = []
        origin_collection[:track_froms].each_with_index do |track_from, index|
          track_from_label = origin_collection[:track_from_names][index]
          row = []
          row << track_from_label
          origin_collection[:types].each_with_index do |type|
            item = items.detect{|item| item[:type] == type && item[:track_from] == track_from }
            row << (item.present? ? item[:times] : 0)
            row << (item.present? ? item[:total] : 0)
          end
          content << row
        end
        row = ["总计"]
        origin_collection[:types].each do |type|
          same_type_items = items.select{|item| item[:type] == type}
          row << sum(same_type_items, :times)
          row << sum(same_type_items, :total)
        end
        content << row
        content
      end

    end
  end
end
