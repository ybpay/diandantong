module Ddt
  module WorkerStatistic
    class Serve < WorkerStatistic::Base

      def self.class_info
        {
          name: 'serve',
          paginate: false,
          permit_params: [:branch_id, :start_time, :end_time],
          default_params: today,
          label: '点菜员统计',
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
            },
            group_by: :waiter_id
        }
        query = params[:query]

        @items = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:waiter_id],
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
              waiter_id:          line_item.waiter_id,
              adjustment_total:   line_item.adjustment_total,
              total:              line_item.total,
              guest_num:          line_item.guest_num,
              times:              line_item.times
            }
          }
        end
      end

      cache_result

      def title
        %W[点菜员 点单量 金额 单均]
      end

      def body
        items = result
        accounts = Ddt::Account.with_discarded.where(shop_id: shop.id, id: (items.map {|item| item[:waiter_id]}).compact)
        content = []
        items.each do |item|
          if item[:waiter_id].blank?
            waiter_name = '未记录'
          else
            waiter = accounts.detect{|w| w.id == item[:waiter_id]}
            waiter_name = waiter.present? ? waiter.name : '未记录'
          end
          content << [
            waiter_name,
            item[:times],
            item[:total],
            avg(item[:total], item[:times])
          ]
        end
        content
      end

      def foot
        items = result
        [['总计',sum(items, :times),'','']]
      end

    end
  end
end
