module Ddt
  module Api
    module V1
      module Backend
        class ReservationOrdersController < Ddt::Api::V1::BaseController
          before_action :set_branch
          before_action :set_order, only: [:show, :confirm, :cancel, :complete]

          def index
            orders = @branch.reservation_orders.includes(:pay_items, :line_items)
                        .order(placed_at: :desc)
                        .ransack(params[:q]).result
            render_paginated(orders)
          end

          def show
            render_resource(@order)
          end

          def confirm
            @order.confirm! if @order.may_confirm?
            render_resource(@order)
          end

          def cancel
            @order.cancel!(params[:reason]) if @order.may_cancel?
            render_resource(@order)
          end

          def complete
            @order.complete! if @order.may_complete?
            render_resource(@order)
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def set_order
            @order = @branch.reservation_orders.find(params[:id])
          end
        end
      end
    end
  end
end
