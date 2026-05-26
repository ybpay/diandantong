module Ddt
  module Api
    module V1
      module Backend
        class OrdersController < Ddt::Api::V1::BaseController
          before_action :set_branch
          before_action :set_order, only: [:show, :update]
          check_permission :branch, :order, base_permission_actions

          def index
            orders = @branch.orders.includes(:pay_items, :line_items)
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

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def set_order
            @order = @branch.orders.includes(:line_items, :adjustments, :form_contents, :pay_items).find(params[:id])
          end

          def order_params
            params.require(:order).permit(:state, :note)
          end
        end
      end
    end
  end
end
