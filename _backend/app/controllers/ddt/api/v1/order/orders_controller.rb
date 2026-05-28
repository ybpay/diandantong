module Ddt
  module Api
    module V1
      module Backend
        class OrdersController < Ddt::Api::V1::BaseController
          before_action :set_branch
          before_action :set_order, only: [:show, :update, :confirm, :cancel, :complete, :refund]
          check_permission :branch, :order, base_permission_actions

          def index
            orders = @branch.orders.includes(:pay_items, :line_items, :adjustments)
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

          def refund
            if @order.may_init_refund?
              @order.init_refund!
              render_resource(@order)
            else
              render_errors({ state: "当前状态不允许退款" }, :bad_request)
            end
          end

          def batch_change_state
            order_ids = params[:order_ids]
            raise ActionController::ParameterMissing, "order_ids" if order_ids.blank?

            state_action = params[:state_action]
            raise ActionController::ParameterMissing, "state_action" unless state_action.in?(%w[confirm cancel complete])

            errors = []
            orders = @branch.orders.where(id: order_ids)
            orders.each do |order|
              case state_action
              when "confirm" then order.may_confirm? ? order.confirm! : errors << "Order##{order.id} 无法确认"
              when "cancel" then order.may_cancel? ? order.cancel!(params[:reason]) : errors << "Order##{order.id} 无法取消"
              when "complete" then order.may_complete? ? order.complete! : errors << "Order##{order.id} 无法完成"
              end
            rescue => e
              errors << "Order##{order.id}: #{e.message}"
            end

            if errors.any?
              render json: { data: { success: false, errors: errors } }, status: :multi_status
            else
              render_empty_success(message: "批量操作成功")
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
