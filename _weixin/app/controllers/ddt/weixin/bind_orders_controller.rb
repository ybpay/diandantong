module Ddt
  class Weixin::BindOrdersController < Ddt::BaseWeixinController
    check_feature :weixin

    before_action :set_order, only: [:show, :bind, :vip_info]
    layout 'ddt/layouts/bind_order'
    def show
      ActiveRecord::Base.transaction do
        if @order.current_vip.blank? || (@order.user.present? && @order.user.is_a?(Ddt::PhoneUser))
          @order.change_vip_info(@current_user.vip_info)
          @order.update_total_and_save
        end
      end
    end

    def bind
      pay_method = params[:bind_order][:pay_method].to_sym
      ActiveRecord::Base.transaction do
        pay_itemable = OrderService::PayItemable.new(name_sym: pay_method, amount: @order.amount_for_pay, shop: @current_shop)
        case pay_method
        when :alipay, :wechatpay
          @payment = @order.load_pay_item(pay_itemable).payment
          result = @payment.process(request, callback_url: "http://#{request.host}:#{request.port}/#{@order.weixin_show_path}")
          redirect_to root_path + @order.weixin_show_path + "&pay_online=true"
        when :vip_card_pay
          pay_item = @order.load_pay_item(pay_itemable)
          if @current_user.vip_info.authenticate(params[:bind_order][:password])
            @order.change_pay_item_to_paid(pay_item)
            flash[:notice] = '支付成功'
          else
            flash[:notice] = '支付密码错误'
          end
          redirect_to weixin_shop_bind_order_path(@current_shop, @order)
        end
      end
    rescue => e
      flash[:notice] = e.message
      redirect_to weixin_shop_bind_order_path(@current_shop, @order)
    end

    private
    def set_order
      @order = @current_shop.orders.find(params[:id])
      @all_pay_methods = @order.branch.all_pay_methods[@order.type_str.to_sym]
    end

  end
end
