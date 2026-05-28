module Ddt
  module Api
    module Admin
      module V1
        class OrdersController < BaseController
          before_action :set_order, only: [:show, :update, :confirm, :cancel, :complete]

          def index
            orders = Ddt::Order.joins(:branch).where(branches: { shop_id: current_shop.id })
                        .includes(:line_items, :pay_items)
                        .order(placed_at: :desc)
                        .ransack(params[:q]).result
            render_paginated(orders)
          end

          def show
            render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items, :adjustments]) })
          end

          def update
            if @order.update(order_params)
              render_resource(@order)
            else
              render_errors(@order.errors)
            end
          end

          def confirm
            if @order.may_confirm?
              @order.confirm!
              render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items]) })
            else
              render_errors({ state: "当前状态不允许确认" }, :bad_request)
            end
          end

          def cancel
            if @order.may_cancel?
              @order.cancel!(params[:reason])
              render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items]) })
            else
              render_errors({ state: "当前状态不允许取消" }, :bad_request)
            end
          end

          def complete
            if @order.may_complete?
              @order.complete!
              render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items]) })
            else
              render_errors({ state: "当前状态不允许完成" }, :bad_request)
            end
          end

          private

          def set_order
            @order = Ddt::Order.joins(:branch).where(branches: { shop_id: current_shop.id }).find(params[:id])
          end

          def order_params
            params.require(:order).permit(:state, :note)
          end
        end
      end
    end
  end
end
