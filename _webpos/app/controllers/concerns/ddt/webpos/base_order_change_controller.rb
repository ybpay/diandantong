module Ddt
  module Webpos
    module BaseOrderChangeController
      extend ActiveSupport::Concern
      included do
        actions_map = {
          append: :append,
          [:active_line_items, :subtract] => :subtract,
        }
        check_permission :branch, :order, actions_map, only: actions_map.keys.map{|k| Array(k)}.inject(:+)
      end

      def append
        @order.is_local_printed = params[:is_local_printed]
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
