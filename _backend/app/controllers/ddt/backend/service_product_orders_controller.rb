# encoding: utf-8
module Ddt
  class Backend::ServiceProductOrdersController < Backend::BaseController
    before_action :set_service_product_order, only: [:show, :pay_with_alipay]

    def index
      if current_account.is_admin? && @current_shop.nil?
        @q = ServiceProductOrder.all.ransack(params[:q])
        @service_product_orders = @q.result(distinct: true).paginate(page: params[:page])
      elsif current_account.is_boss?
        @q = @current_shop.service_product_orders.ransack(params[:q])
        @service_product_orders = @q.result(distinct: true).paginate(page: params[:page])
      end
    end

    def show
    end

    def create
      service_product = ServiceProduct.find(params[:service_product_id])
      @service_product_order = @current_shop.service_product_orders.build({
        out_trade_no: Time.now.strftime("%Y%m%d%H%M%S%s"),
        subject: service_product.subject,
        price: service_product.price,
        quantity: 1,
        discount: 0,
        service_product: service_product
      })

      if @service_product_order.save
        redirect_to [:backend, @current_shop, @service_product_order]
      else
        flash[:error] = @service_product_order.errors.full_messages.join(",")
        redirect_to backend_shop_service_products_path(@current_shop)
      end
    end

    def pay_with_alipay
      pay_by_order_with_alipay(@service_product_order)
    end

    private
    def pay_by_order_with_alipay(service_product_order)
      options = {
      :out_trade_no      => service_product_order.out_trade_no,
      :subject           => service_product_order.subject,
      :price             => service_product_order.price,
      :quantity          => service_product_order.quantity,
      :discount          => service_product_order.discount,
      :logistics_type    => 'DIRECT',
      :logistics_fee     => '0',
      :logistics_payment => 'SELLER_PAY',
      :return_url        => backend_shop_service_product_order_url(@current_shop, service_product_order.id),
      :notify_url        => system_alipay_notify_url(service_product_order.id),
      }

      Ddt::AlipayMethod.use_system_alipay
      url = Alipay::Service.create_direct_pay_by_user_url(options)
      redirect_to url
    end

    def set_service_product_order
      if current_account.is_admin?
        @service_product_order = ServiceProductOrder.find(params[:id])
      elsif current_account.is_boss?
        @service_product_order = @current_shop.service_product_orders.find(params[:id])
      end
    end

  end
end
