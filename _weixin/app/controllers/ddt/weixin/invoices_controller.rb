module Ddt
  class Weixin::InvoicesController < WeixinApplicationController
    before_action :set_order

    def create
      @invoice = @order.create_invoice(invoice_params)
      if @invoice.valid?
        render json: {}
      else
        render json: { errors: @invoice.errors.full_messages }, status: :bad_request
      end
    end

    private

    def set_order
      @order = @current_user.orders.find(params[:order_id])
    end

    def invoice_params
      params.require(:invoice).permit(:payer, :title, :order_id)
    end

  end
end