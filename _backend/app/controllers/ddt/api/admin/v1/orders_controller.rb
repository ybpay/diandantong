module Ddt
  module Api
    module Admin
      module V1
        class OrdersController < BaseController
          before_action :set_order, only: [:show, :update]

          def index
            orders = Ddt::Order.joins(:branch).where(branches: { shop_id: current_shop.id }).ransack(params[:q]).result
            render_paginated(orders)
          end

          def show
            render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items]) })
          end

          def update
            if @order.update(order_params)
              render_resource(@order)
            else
              render_errors(@order.errors)
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
