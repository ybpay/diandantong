module Ddt
  module Webpos
    module Order
      class LineItemsController < Webpos::BaseController
        before_action :set_order
        before_action :set_line_item
        check_permission :branch, :order, { change_price: :change_item_price }, only: [:change_price]

        def change_price
          if @order.change_line_item_price(@line_item.id, params[:new_price].to_f)
            render json: :ok
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        private

        def set_order
          @order = @current_branch.orders.find(params[:order_id])
        end

        def set_line_item
          @line_item = @order.line_items.find(params[:id])
        end
      end
    end
  end
end
