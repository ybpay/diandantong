# encoding: utf-8
module Ddt
  module UserStatistic
    class NewUser < ::Ddt::UserStatistic::Base

      def self.class_info
        {
          name: 'new_user',
          paginate: false,
          permit_params: [:start_time, :end_time],
          label: '用户数据统计'
        }
      end

      def result
        # TODO: 需要进一步优化
        new_vip_infos = shop.vip_infos.where(created_at: start_time..end_time)
        vip_info_count = shop.vip_infos.count
        all_vip = shop.vip_infos.not_default_level
        all_vip_count = all_vip.count
        recharge_vip_count = shop.wallet_logs.joins(:wallet).where(ddt_wallets: { type: "Ddt::UserCardWallet" }, reason: :for_recharge).count("DISTINCT wallet_id")
        multi_recharge_vip_count = shop.wallet_logs.joins(:wallet).where(ddt_wallets: { type: "Ddt::UserCardWallet" }, reason: :for_recharge).group(:wallet_id).having("count(*) > ?",1).count.size

        if all_vip_count > 0
          query_params = {
            shop_id_eq: shop.id,
            paid_at_gteq: start_time,
            paid_at_lteq: end_time,
            vip_info_id_in: all_vip.pluck(:id)
          }
          order_count = OrderService::Api::Statistic.order_quantity(query: query_params)
          distinct_vip_order_count = OrderService::Api::Statistic.order_quantity(query: query_params, count: "DISTINCT vip_info_id")
          order_total = OrderService::Api::Statistic.order_sale_amount(query: query_params)
          per_order_amount = order_count > 0 ? (order_total / order_count).to_f.round(2) : 0
        else
          order_count = 0
          distinct_vip_order_count = 0
          per_order_amount = 0
        end
        [{
          vip_info_count: vip_info_count,
          vip_count: all_vip_count,
          new_user_count: new_vip_infos.count,
          new_vip_count: new_vip_infos.not_default_level.count,
          recharge_vip_count: recharge_vip_count,
          multi_recharge_vip_count: multi_recharge_vip_count,
          distinct_vip_order_count: distinct_vip_order_count,
          order_count: order_count,
          per_order_amount: per_order_amount
        }.to_obj]
      end
      cache_result

      def filters
        [
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %W[用户人数 会员人数 新用户数 新会员数 充值人数 多次充值人数 消费人数 消费次数 平均消费]
      end

      def body
        items = self.result
        content = []
        items.each do |item|
          content << [
            item.vip_info_count,
            item.vip_count,
            item.new_user_count,
            item.new_vip_count,
            item.recharge_vip_count,
            item.multi_recharge_vip_count,
            item.distinct_vip_order_count,
            item.order_count,
            item.per_order_amount,
          ]
        end
        content
      end

    end
  end
end
