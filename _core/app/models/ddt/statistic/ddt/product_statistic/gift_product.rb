#encoding: utf-8
module Ddt
  module ProductStatistic
    class GiftProduct < ::Ddt::ProductStatistic::Base
      include Ddt::CacheModel
      cache_model 'Ddt::Account', with_deleted: true

      attr_accessor :order_number, :gift_reason, :records
      hash_attrs({
          订单号: :order_number,
          赠菜原因: :gift_reason
      })

      def self.class_info
        {
          name: 'gift_product',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id, :order_number, :gift_reason],
          default_params: today,
          label: '赠菜记录',
          sortable: true
        }
      end

      def initialize(options={})
        super
        @order_number = options[:order_number]
        @gift_reason = options[:gift_reason]
      end

      def to_params
        {
          branch_id: branch_id,
          start_time: start_time,
          end_time: end_time
        }
      end

      def result
        return @records if @records.present?
        params = {
            query: {
                shop_id_eq: shop.id,
                branch_id_eq: branch_id,
                order_number_eq: order_number,
                gift_reason_eq: gift_reason
            }
        }
        query = params[:query]

        @records ||= split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id, :order_id, :order_number, :table_name, :table_zone_name, :waiter_id, :created_at, :itemable_type, :itemable_id, :itemable_name, :product_name, :original_price, :gift_reason],
            accumulate_keys: [:quantity]
        ) do |current_date, next_date, has_next|
          # Rails.logger.info("[Statistics][GiftProduct] shop=#{shop.id}, branch=#{branch.id}, current_date=#{current_date}, next_date=#{next_date}, has_next=#{has_next}")
          query[:created_at_gteq] = current_date
          if (has_next)
            query[:created_at_lt] = next_date
          else
            query.delete(:created_at_lt)
            query[:created_at_lteq] = next_date
          end
          Ddt::OrderService::Api::Statistic.gift_item_list(params)
        end
      end
      cache_result

      def filters
        [
          filter_branch(support_all: false),
          {name: 'order_number', type: 'string', placeholder: '订单号'},
          {name: 'gift_reason', type: 'collection', collection: shop.gift_reasons.map(&:name), prompt: '赠菜理由', include_blank: true},
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %W[单号 产品编号（sku） 赠菜桌台 菜品 单位 菜品金额 赠送数量 赠送金额 赠菜人 赠菜理由 赠菜时间]
      end

      def body
        items = result
        content = []
        items.each do |item|
          account = get_account(item[:waiter_id])
          account_name = account.nil? ? '-' : account.name
          content << [
            item[:order_number],
            sku(item[:itemable_type], item[:itemable_id]),
            item[:table_name],
            item[:itemable_name],
            unit_name(item[:itemable_type], item[:itemable_id]),
            item[:original_price],
            item[:quantity],
            item[:original_price] * item[:quantity],
            account_name,
            item[:gift_reason],
            item[:created_at]
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
        items = result
        order_number_id_hash(items)
      end

    end
  end
end
