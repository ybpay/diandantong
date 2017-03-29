module Ddt
  module CommonApi
    module V1
      module Order
        class PaymentOrdersController < V1::BaseController
          include V1::BaseOrderController
          check_permission :branch, :payment_order, { create: :create }, only: [:create]
          def create
            @cart = OrderService::Cart::Payment.new(base_cart_params.merge(
                note: params[:note],
                payment_price: params[:amount].to_f
              ))
            @order = @cart.place
            if @order
              render json: { order: { id: @order.id }}
            else
              render json: { errors: @cart.errors.full_messages }, status: :bad_request
            end
          end
        end
      end
    end
  end
end
