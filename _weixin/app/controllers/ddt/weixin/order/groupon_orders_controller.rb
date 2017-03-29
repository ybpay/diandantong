#encoding: utf-8
module Ddt
  class Weixin::Order::GrouponOrdersController < WeixinApplicationController
    include Weixin::BaseOrderController
    def create
      @cart.note       = order_params[:note]
      @cart.pay_method = order_params[:pay_method]
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
      params.require(:order).permit(:note, :pay_method)
    end
  end
end