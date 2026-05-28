module Ddt
  module Api
    module Admin
      module V1
        class DeliveryOrdersController < BaseController
          before_action :set_order, only: [:show, :assign, :start, :ship]

          def index
            orders = Ddt::DeliveryOrder.joins(:branch).where(branches: { shop_id: current_shop.id })
                        .includes(:line_items, :pay_items, :adjustments)
                        .order(placed_at: :desc)
                        .ransack(params[:q]).result
            render_paginated(orders)
          end

          def show
            render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items, :adjustments]) })
          end

          def assign
            raise ActionController::ParameterMissing, "delivery_man_id" if params[:delivery_man_id].blank?
            if @order.assign_delivery_man?
              @order.assign_delivery_man(params[:delivery_man_id])
              render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items]) })
            else
              render_errors({ state: "当前状态不允许分配骑手" }, :bad_request)
            end
          end

          def start
            if @order.shipment&.may_start?
              @order.start_shipment
              render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items]) })
            else
              render_errors({ state: "当前状态不允许开始配送" }, :bad_request)
            end
          end

          def ship
            if @order.shipment&.may_ship?
              @order.ship_shipment
              render_resource(@order, serializer: ->(o) { o.as_json(include: [:line_items, :pay_items]) })
            else
              render_errors({ state: "当前状态不允许确认送达" }, :bad_request)
            end
          end

          private

          def set_order
            @order = Ddt::DeliveryOrder.joins(:branch).where(branches: { shop_id: current_shop.id }).find(params[:id])
          end
        end
      end
    end
  end
end
