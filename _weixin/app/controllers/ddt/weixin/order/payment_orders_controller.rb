module Ddt
  class Weixin::Order::PaymentOrdersController < WeixinApplicationController
    include Weixin::BaseOrderController
    def create
      @cart.pay_method = order_params[:payment_method]
      @cart.update_payment_price(order_params[:amount].to_f)
      @order = @cart.place
      if @order
        clear_cart
        render json: { order: { id: @order.id }}
      else
        render json: { errors: @cart.errors.full_messages }, status: :bad_request
      end
    end

    private
    def order_params
      params.require(:order).permit(:amount, :payment_method)
    end

  end
end