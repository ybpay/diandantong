module Ddt
  class Weixin::Order::ReservationOrdersController < WeixinApplicationController
    include Weixin::BaseOrderController
    def create
      @cart.update_reservation_info(order_params.slice(:name, :phone, :gender))
      @cart.update_prepayment_type(order_params[:prepayment_type])
      @cart.note = order_params[:note]
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

    private
    def order_params
      params.require(:order).permit(:name, :phone, :gender, :prepayment_type, :note, :pay_method)
    end
  end
end
