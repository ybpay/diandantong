module Ddt
  class Weixin::Cart::EatInHallCartsController < WeixinApplicationController
    include Weixin::BaseCartController
    include Weixin::BaseCartCouponController
    def update_table_info
      @cart.update_table_info(table_info_params)
      render :show
    end

    def set_order_itemables_from_table
      @table = @branch.tables.find(params[:table_id])
      @cart.set_order_itemables_from_table(@table)
      render :show
    end

    def update_cart
      line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
      @cart.update_line_items(line_itemables)
      @cart.update_discount
      @adapter.update_from_cart(@cart)
      render :show
    end

    def after_clear_cart
      @adapter.update_from_cart(@cart)
    end

    def after_add_itemable
      @adapter.update_from_cart(@cart)
    end

    def after_remove_itemable
      @adapter.update_from_cart(@cart)
    end

    def after_add_combo_package_to_cart
      @adapter.update_from_cart(@cart)
    end

    private
    def table_info_params
      params.require(:cart).permit(:table_id, :guest_num)
    end

    def set_cart
      @adapter = Ddt::OrderItemable::Adapter.get_from(session)
      if @adapter.valid?
        @cart = @adapter.get_cart(@branch, @current_user, session)
      else
        @adapter.detach(session)
        render json: {custom: true, type: 'Cart:InvalidJump', branch_id: @branch.id}, status: :bad_request
      end
    end

  end
end
