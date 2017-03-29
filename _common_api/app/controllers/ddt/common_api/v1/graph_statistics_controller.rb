module Ddt
  module CommonApi
    module V1
      class GraphStatisticsController < V1::BaseController
        layout "/ddt/layouts/graph_statistic"
        respond_to :html
        before_action :set_statistic_params
        after_action :allow_iframe
        def product_sale
          @sale_acount_statistic = Statistic::Product::SaleCount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date)
          @sale_amount_statistic = Statistic::Product::SaleAmount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date)
        end

        def product_category_sale
          @sale_acount_statistic = Statistic::Product::SaleCount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, group_by: "category_names")
          @sale_amount_statistic = Statistic::Product::SaleAmount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, group_by: "category_names")
        end

        def business
          @actual_amount_statistic = Statistic::Business::ActualAmount.new(shop_id: current_shop.id, q: { type_in: OrderService::Order::Base.base_types }, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @not_actual_amount_statistic = Statistic::Business::NotActualAmount.new(shop_id: current_shop.id, q: { type_in: OrderService::Order::Base.base_types }, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @recharge_amount_statistic = Statistic::Business::RechargeAmount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @discount_amount_statistic = Statistic::Business::DiscountAmount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @guest_num_statistic = Statistic::Business::GuestNum.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @order_quantity_statistic = Statistic::Order::Quantity.new(shop_id: current_shop.id, q: { type_in: OrderService::Order::Base.base_types }, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @order_sales_statistic = Statistic::Order::Sales.new(shop_id: current_shop.id, q: { type_in: OrderService::Order::Base.base_types }, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
        end

        def order_track_from
          @statistic = Statistic::Order::Quantity.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day, group_by: [:track_from])
        end

        def user_source
          @new_vip_count_statistic = Statistic::Vip::NewCount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @subscription_count_statistic = Statistic::Vip::SubscriptionCount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
        end

        def vip_amount
          @recharge_actual_amount_statistic = Statistic::Vip::RechargeActualAmount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @recharge_not_actual_amount_statistic = Statistic::Vip::RechargeNotActualAmount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @pay_actual_amount_statistic = Statistic::Vip::PayActualAmount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @pay_not_actual_amount_statistic = Statistic::Vip::PayNotActualAmount.new(shop_id: current_shop.id, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
        end

        def suspicious_order
          @cancel_order_statistic = Statistic::Order::CancelQuantity.new(shop_id: current_shop.id, q: { type_in: OrderService::Order::Base.base_types }, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
          @anti_settlement_order_statistic = Statistic::Order::Quantity.new(shop_id: current_shop.id, q: { anti_settlement_eq: true, type_in: OrderService::Order::Base.base_types }, branch_id: @branch_id, start_date: @start_date, end_date: @end_date, interval: :day)
        end

        private
        def set_statistic_params
          unless params[:all_branches]
            @branch_id = params[:branch_id] || current_shop.branches.first.id
            @branch = Ddt::Branch.where(id: @branch_id).first
          end
          @start_date = params[:start_date].present? ? DateTime.parse(params[:start_date]).to_date : 1.week.ago.beginning_of_week.to_date
          @end_date = params[:end_date].present? ? DateTime.parse(params[:end_date]).to_date : 1.week.ago.end_of_week.to_date
        end

        def allow_iframe
          response.headers["X-Frame-Options"] = 'ALLOWALL'
        end
      end
    end
  end
end
