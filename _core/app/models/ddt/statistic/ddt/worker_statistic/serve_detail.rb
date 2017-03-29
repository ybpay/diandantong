module Ddt
  module WorkerStatistic
    class ServeDetail < WorkerStatistic::Base

      def self.class_info
        {
          name: 'serve_detail',
          paginate: false,
          permit_params: [:branch_id, :start_time, :end_time],
          default_params: today,
          label: '点菜数统计',
          sortable: true,
          expose_to_api: true
        }
      end

      def result
        return [] if branch_id.blank?
        params = {
          query: {
            shop_id_eq: shop.id,
            branch_id_eq: branch_id,
            order_type_in: Ddt::OrderService::Order::Base.base_types
            }
        }
        query = params[:query]

        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:waiter_id, :itemable_name, :price],
            accumulate_keys: [:quantity, :amount]
        ) do |current_date, next_date, has_next|
          query[:paid_at_gteq] = current_date
          if (has_next)
            query[:paid_at_lt] = next_date
          else
            query.delete(:paid_at_lt)
            query[:paid_at_lteq] = next_date
          end
          Ddt::OrderService::Api::Statistic.serve_detail(params)
        end
      end
      cache_result

      def title
        %W[点菜员 菜品 点菜数量 总额]
      end

      def body
        items = result.map(&:to_obj)
        accounts = Ddt::Account.with_deleted.where(shop_id: shop.id, id: items.map(&:waiter_id).compact)
        content = []
        items.each do |item|
          if item.waiter_id.blank?
            waiter_name = '未记录'
          else
            waiter = accounts.detect{|w| w.id == item.waiter_id}
            waiter_name = waiter.present? ? waiter.name : '未记录'
          end
          content << [
            waiter_name,
            item.itemable_name,
            item.quantity,
            item.amount
          ]
        end
        content
      end




    end
  end
end
