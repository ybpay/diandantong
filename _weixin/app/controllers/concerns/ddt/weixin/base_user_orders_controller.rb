module Ddt
  module Weixin
    module BaseUserOrdersController
      extend ActiveSupport::Concern
      included do
        respond_to :json
        before_action :set_order_type
        before_action :set_order_collection
      end

      def index
        @orders = @order_collection.order(placed_at: :desc).paginate(page: params[:page], per_page: params[:per_page] || 8)
        fresh_when(@orders)
      end

      private
      def set_order_type
        @order_type = controller_name.gsub('_orders', '')
      end

      def set_order_collection
        @order_collection = @current_user.orders.by_type("Ddt::#{@order_type.classify}Order")
      end

    end
  end
end
