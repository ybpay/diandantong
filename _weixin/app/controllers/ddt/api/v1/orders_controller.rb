module Ddt
  module Api
    module V1
      module Weixin
        class OrdersController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def index
            orders = @branch.orders.ransack(params[:q]).result
                         .order(placed_at: :desc)
            render_paginated(orders)
          end

          def show
            order = @branch.orders.includes(:line_items, :adjustments, :pay_items).find(params[:id])
            render_resource(order)
          end

          def create
            order = build_order
            if order.save
              render_resource_created(order)
            else
              render_errors(order.errors)
            end
          end

          private

          def set_branch
            @branch = current_shop&.branches&.find(params[:branch_id]) || Ddt::Branch.find(params[:branch_id])
          end

          def build_order
            @branch.orders.build(order_params.merge(
              account: current_account,
              placed_at: Time.current
            ))
          end

          def order_params
            params.require(:order).permit(:type, :note, :address_id, :table_id)
          end
        end
      end
    end
  end
end
