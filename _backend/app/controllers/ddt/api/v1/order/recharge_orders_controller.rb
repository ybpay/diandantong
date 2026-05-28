module Ddt
  module Api
    module V1
      module Backend
        class RechargeOrdersController < Ddt::Api::V1::BaseController
          before_action :set_branch
          before_action :set_order, only: [:show, :confirm, :cancel, :complete]
          check_permission :branch, :order, {
            [:index, :show] => :show,
            :confirm => :confirm,
            :cancel => :cancel,
            :complete => :complete
          }

          def index
            orders = @branch.recharge_orders.includes(:pay_items, :adjustments)
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

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def set_order
            @order = @branch.recharge_orders.find(params[:id])
          end
        end
      end
    end
  end
end
