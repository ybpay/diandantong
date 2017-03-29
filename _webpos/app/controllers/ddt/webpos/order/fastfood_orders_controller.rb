module Ddt
  module Webpos
    module Order
      class FastfoodOrdersController < Webpos::BaseController
        include Webpos::BaseOrderController
        include Webpos::AntiSettlementController
        check_permission :branch, :fastfood_order, {create: :create, call_customer: :call_customer}, only: [:create, :call_customer]

        def create
          line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
          @cart = OrderService::Cart::Fastfood.new(base_cart_params.merge(
            line_itemables: line_itemables,
            note: params[:cart][:note],
            food_number: params[:cart][:food_number],
          ))
          @order = @cart.place
          if @order
            render json: { order_id: @order.id, type_str: @order.type_str }
          else
            render json: {errors: @cart.errors.full_messages}, status: :bad_request
          end
        end

        def call_customer
          @order.call_customer if @order.present?
          render json: {}
        end

      end
    end
  end
end
