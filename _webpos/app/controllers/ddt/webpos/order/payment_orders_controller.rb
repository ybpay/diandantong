module Ddt
  module Webpos
    module Order
      class PaymentOrdersController < Webpos::BaseController
        include Webpos::BaseOrderController
        check_permission :branch, :payment_order, { create: :create }, only: [:create]
        def create
          @cart = OrderService::Cart::Payment.new(base_cart_params.merge(
              note: params[:note],
              payment_price: params[:amount].to_f
            ))
          @order = @cart.place
          if @order
            render json: { order: { id: @order.id, type_str: @order.type_str }}
          else
            render json: { errors: @cart.errors.full_messages }, status: :bad_request
          end
        end
      end
    end
  end
end
