module Ddt
  module Webpos
    module AntiSettlementController
      extend ActiveSupport::Concern
      included do
        check_permission :branch, :order, { anti_settlement: :anti_settlement }, only: [:anti_settlement]
      end

      def anti_settlement
        if @order.can_anti_settlement?(current_account)
          @order.do_anti_settlement
          if @order.errors.empty?
            if @order.is_eat_in_hall? && @order.table.current_order?(@order)
              render :show
            else
              render json: {
                msg: "已成功反结账，但由于原桌子已有新的订单，请到“订单管理“模块下进行订单处理",
                order: render_to_string(template: "ddt/webpos/order/#{@order.type_str}_orders/show.json.jbuilder")
              }
            end
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        else
          render json: {errors: ['您无权反结账此订单']}, status: :bad_request
        end
      end
    end
  end
end
