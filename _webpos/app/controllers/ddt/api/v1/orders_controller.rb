module Ddt
  module Api
    module V1
      module Webpos
        class OrdersController < Ddt::Api::V1::BaseController
          include Ddt::BatchChangeOrderState
          before_action :set_branch
          before_action :set_order, only: [:show, :update]
          check_permission :branch, :order, {
            [:index, :show, :pending_counts] => :show,
            batch_change_state: :batch_change_state
          }

          def index
            orders = @branch.orders.includes(:pay_items)
                        .order(placed_at: :desc)
                        .ransack(params[:q]).result
            render_paginated(orders)
          end

          def show
            render_resource(@order)
          end

          def update
            if @order.update(order_params)
              render_resource(@order)
            else
              render_errors(@order.errors)
            end
          end

          def pending_counts
            pending = @branch.orders.pending
            render json: {
              data: {
                eat_in_hall: pending.eat_in_hall.count,
                delivery: pending.delivery.count,
                fastfood: pending.fastfood.count,
                reservation: pending.reservation.count,
                payment: pending.payment.count,
                groupon: pending.groupon.count,
                recharge: pending.recharge.count
              }
            }
          end

          def batch_change_state
            batch_change_order_state do |errors|
              if errors.present?
                render json: { errors: [{ status: 400, title: "批量操作失败", detail: errors.join(", ") }] }, status: :bad_request
              else
                render_empty_success(message: "批量操作成功")
              end
            end
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def set_order
            @order = @branch.orders.includes(:line_items, :adjustments, :form_contents, :pay_items).find(params[:id])
          end

          def order_params
            params.require(:order).permit(:state, :note, :placed_at)
          end
        end
      end
    end
  end
end
