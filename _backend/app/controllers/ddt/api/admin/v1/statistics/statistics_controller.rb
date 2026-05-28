module Ddt
  module Api
    module Admin
      module V1
        class StatisticsController < BaseController
          before_action :set_branch

          def business
            render json: { data: gather_business_stats }
          end

          def orders
            orders = @branch.orders.ransack(params[:q]).result
            render_paginated(orders)
          end

          def products
            render json: { data: gather_product_stats }
          end

          def finance
            render json: { data: gather_finance_stats }
          end

          def coupons
            render json: { data: gather_coupon_stats }
          end

          def workers
            render json: { data: gather_worker_stats }
          end

          private

          def set_branch
            @branch = if params[:branch_id]
                        current_shop.branches.find(params[:branch_id])
                      else
                        current_shop.branches.first
                      end
          end

          def time_range
            @time_range ||= begin
              start_time = params[:start_date] ? Time.parse(params[:start_date]) : Time.current.beginning_of_day
              end_time = params[:end_date] ? Time.parse(params[:end_date]) : Time.current
              start_time..end_time
            end
          end

          def gather_business_stats
            orders = @branch.orders.where(placed_at: time_range)
            {
              total_orders: orders.count,
              total_revenue: orders.sum(:total),
              avg_order_amount: orders.average(:total),
              time_range: { start: time_range.begin, end: time_range.end }
            }
          end

          def gather_product_stats
            line_items = Ddt::LineItem.joins(:order).where(orders: { branch_id: @branch.id, placed_at: time_range })
            {
              top_products: line_items.group(:product_id).order("count_id DESC").limit(20).count(:id),
              time_range: { start: time_range.begin, end: time_range.end }
            }
          end

          def gather_finance_stats
            payments = Ddt::PayItem.joins(:order).where(orders: { branch_id: @branch.id, placed_at: time_range })
            {
              total_amount: payments.sum(:amount),
              by_method: payments.group(:pay_method).sum(:amount),
              time_range: { start: time_range.begin, end: time_range.end }
            }
          end

          def gather_coupon_stats
            coupons = @branch.coupons.where(created_at: time_range)
            {
              total_coupons: coupons.count,
              used_coupons: coupons.where.not(applied_at: nil).count,
              expired_coupons: coupons.where("expires_at < ?", Time.current).count,
              time_range: { start: time_range.begin, end: time_range.end }
            }
          end

          def gather_worker_stats
            orders = @branch.orders.where(placed_at: time_range)
            {
              total_served: orders.count,
              by_worker: orders.group(:worker_id).count,
              time_range: { start: time_range.begin, end: time_range.end }
            }
          end
        end
      end
    end
  end
end
