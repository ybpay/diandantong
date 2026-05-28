module Ddt
  module Api
    module V1
      module Backend
        class DeliveryOrdersController < Ddt::Api::V1::BaseController
          before_action :set_branch
          before_action :set_order, only: [:show, :confirm, :cancel, :complete, :assign, :start, :ship]
          check_permission :branch, :order, {
            [:index, :assigned, :show] => :show,
            :confirm => :confirm,
            :cancel => :cancel,
            :complete => :complete,
            :assign => :update,
            :start => :update,
            :ship => :update
          }

          def index
            orders = @branch.delivery_orders.includes(:pay_items, :line_items, :adjustments)
                        .order(placed_at: :desc)
                        .ransack(params[:q]).result
            render_paginated(orders)
          end

          def assigned
            orders = @branch.delivery_orders.where.not(delivery_man_id: nil)
                        .includes(:pay_items, :line_items, :adjustments)
                        .order(placed_at: :desc)
                        .ransack(params[:q]).result
            render_paginated(orders)
          end

          def show
            render_resource(@order)
          end

          def confirm
            if @order.may_confirm?
              @order.confirm!
              render_resource(@order)
            else
              render_errors({ state: "当前状态不允许确认" }, :bad_request)
            end
          end

          def cancel
            if @order.may_cancel?
              @order.cancel!(params[:reason])
              render_resource(@order)
            else
              render_errors({ state: "当前状态不允许取消" }, :bad_request)
            end
          end

          def complete
            if @order.may_complete?
              @order.complete!
              render_resource(@order)
            else
              render_errors({ state: "当前状态不允许完成" }, :bad_request)
            end
          end

          def assign
            raise ActionController::ParameterMissing, "delivery_man_id" if params[:delivery_man_id].blank?
            @order.assign_delivery_man(params[:delivery_man_id])
            render_resource(@order)
          end

          def start
            @order.start_shipment
            render_resource(@order)
          end

          def ship
            @order.ship_shipment
            render_resource(@order)
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def set_order
            @order = @branch.delivery_orders.find(params[:id])
          end
        end
      end
    end
  end
end
