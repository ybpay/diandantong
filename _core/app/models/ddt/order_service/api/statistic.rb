#encoding: utf-8
module Ddt
  module OrderService
    module Api
      class Statistic
        include OrderService::Api::Base

        statistics = [
          :orders,
          :order_quantity,
          :order_amount,
          :order_moling_amount,
          :order_sale_amount,
          :line_item_quantity,
          :variant_sale_quantity,
          :combo_sale_quantity,
          :combo_item_list,
          :line_item_list,
          :by_weight_product_sale_list,
          :gift_item_list,
          :subtract_item_list,
          :subtract_item_amount,
          :variant_sale_amount,
          :variant_sale_summary,
          :combo_sale_amount,
          :combo_sale_summary,
          :combo_sale_list,
          :pay_item_amount,
          :pay_item_actual_amount,
          :pay_item_not_actual_amount,
          :guest_num_count,
          :adjustment_list,
          :adjustment_amount,
          :order_change_list,
          :order_change_count,
          :order_times_total,
          :order_privilege_discount_list,
          :gift_product,
          :gift_summary,
          :pay_item_list,
          :order_discount_list,
          :serve_detail,
          :guest_num,
        ]

        statistics.each do |s|
          define_singleton_method s do |options={}|
            get "/statistic/#{s}", options
            # 统计结果都使用symbol 作为Hash 的key
          end
        end

        mock_for *statistics

      end
    end
  end
end
