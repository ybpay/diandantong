# encoding:utf-8
module Ddt
  class Weixin::Order::FastfoodOrdersController < WeixinApplicationController
    include Weixin::BaseOrderController

    def create
      @cart.note       = order_params[:note]
      @cart.pay_method = order_params[:pay_method]
      form_contentables = OrderService::FormContentable.init_list(params.fetch(:order,{}).fetch(:form_contents, []))
      @cart.update_form_contents(form_contentables)
      @order = @cart.place
      if @order
        clear_cart
        render json: { order: { id: @order.id }}
      else
        render json: { errors: @cart.errors.full_messages }, status: :bad_request
      end
    end

    def call_waiter
      @order.call_waiter(params[:service_name])
      render json: {}
    end

    private
    def order_params
      params.require(:order).permit(:note, :pay_method)
    end
  end
end
