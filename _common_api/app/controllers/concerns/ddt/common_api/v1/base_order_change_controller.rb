
module Ddt
  module CommonApi
    module V1
      module BaseOrderChangeController
        extend ActiveSupport::Concern
        included do
          check_permission :branch, :order, {
            append: :append,
            [:active_line_items, :subtract] => :subtract,
          }, only: [:append, :active_line_items, :subtract]
        end

        # params: {
        #   itemables: [{:itemable_type, :itemable_id, :quantity}]
        #   note: "note"
        # }
        def append
          line_itemables = OrderService::LineItemable.init_list(params[:itemables])
          if @order.can_append_itemable?(need_errors: true)
            if @order.append(line_itemables, params[:note])
              render :show
            else
              render json: { errors: @order.errors.full_messages }, status: :bad_request
            end
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def active_line_items
          @active_line_items = @order.active_line_items
        end

        # params: {
        #   subtractables: [{:line_item_id, :quantity}]
        # }
        def subtract
          subtractables = OrderService::Subtractable.init_list(params[:subtractables], order: @order)
          if @order.can_subtract_itemable?(need_errors: true)
            @order.subtract(subtractables)
            render :show
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

      end
    end
  end
end
