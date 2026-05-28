module Ddt
  module ProductStatistic
    class GiftSummary < ::Ddt::ProductStatistic::Base
      include Ddt::CacheModel
      cache_model 'Ddt::Account', with_discarded: true

      def self.class_info
        {
          name: 'gift_summary',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id],
          default_params: today,
          label: '赠菜统计',
          sortable: true,
          expose_to_api: true
        }
      end


      def result
        return [] if branch_id.blank?
        params = {
            query: {
                shop_id_eq: shop.id,
                branch_id_eq: branch_id
            }
        }
        query = params[:query]

        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:branch_id, :order_id, :order_number, :table_name, 
                            :table_zone_name, :waiter_id, :created_at, :itemable_type, 
                            :itemable_id, :itemable_name, :product_name, :original_price, 
                            :gift_reason],
            accumulate_keys: [:quantity]
        ) do |current_date, next_date, has_next|
          # Rails.logger.info("[Statistics][GiftSummary] shop=#{shop.id}, branch=#{branch.id}, current_date=#{current_date}, next_date=#{next_date}, has_next=#{has_next}")
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
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %W[产品编号（sku） 菜品 单位 菜品金额 赠送数量 赠送金额 赠菜理由]
      end

      def body
        items = result
        items = group_by_itemable_id(items)
        content = []
        items.each do |item|
          content << [
            sku(item[:itemable_type], item[:itemable_id]),
            item[:itemable_name],
            unit_name(item[:itemable_type], item[:itemable_id]),
            item[:original_price],
            item[:sum_quantity],
            item[:sum_amount],
            item[:reasons]
          ]
        end
        content
      end

      def foot
        items = result
        items = group_by_itemable_id(items)
        [['总计','-','-','-',sum(items, :sum_quantity),sum(items, :sum_amount),'-']]
      end

      def group_by_itemable_id(items)
        hash = group(items, :itemable_id)
        hash.map do |k, v|
          first = v[0]
          sum_quantity = sum(v, :quantity)
          sums = {
            sum_quantity: sum_quantity,
            sum_amount:   sum(v){|item| item[:original_price] * item[:quantity]},
            reasons:      count_join(v, :gift_reason)
          }
          first.merge(sums)
        end
      end


    end
  end
end
