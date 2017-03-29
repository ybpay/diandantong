module Ddt
  module WorkerStatistic
    class Delivery < WorkerStatistic::Base

      def self.class_info
        {
          name: 'delivery',
          paginate: false,
          permit_params: [:branch_id, :start_time, :end_time],
          default_params: today,
          label: '配送员统计',
          sortable: true,
          expose_to_api: true
        }
      end

      def result
        return [] if branch_id.blank?
        # @items ||= Ddt::Shipment.where(shop_id: shop.id, branch_id: branch_id, shipped_at: start_time..end_time).group(:delivery_man_id)
        params = {
            shop_id: shop.id,
            branch_id: branch_id
        }
        @items_split = split_query_by_time(
            start_time: start_time,
            end_time: end_time,
            identity_keys: [:delivery_man_id],
            accumulate_keys: [:count]
        ) do |current_date, next_date, has_next|
          Ddt::Shipment
              .select('delivery_man_id, count(*) as count')
              .where(params.merge(shipped_at: has_next ? current_date...next_date : current_date..next_date))
              .group(:delivery_man_id).map{|line_item|
            {
                delivery_man_id:   line_item.delivery_man_id,
                count:             line_item.count
            }
          }
        end
        @items = Hash.new
        @items_split.each do |hash|
          @items.merge!(hash[:delivery_man_id]=>hash[:count])
        end
        @items
      end
      cache_result

      def title
        %W[配送员 配送订单数]
      end

      def body
        items = result
        return [] if branch_id.blank?
        content = []
        accounts = Ddt::Account.with_deleted.where(shop: shop.id, id: items.keys.compact)
        items.each do |account_id, count|
          if account_id.blank?
            account_name = '未记录'
          else
            account = accounts.detect{|a| a.id == account_id}
            account_name = account.present? ? account.name : '未记录'
          end
          content << [
            account_name,
            count
          ]
        end
        content
      end

      def foot
        items = result
        sum = items.size == 0 ? 0 : items.values.sum
        [['总计', sum]]
      end

    end
  end
end
