#encoding: utf-8
module Ddt
  class Weixin::Order::DeliveryOrdersController < WeixinApplicationController
    include Weixin::BaseOrderController

    def create
      @cart.note       = order_params[:note]
      @cart.pay_method = order_params[:pay_method]
      @cart.update_shipment(order_params[:shipment])
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

    def refresh_location
      location = @order.shipment.deliveryman_location
      if location.present?
        render partial: '/ddt/weixin/order/delivery_orders/location', locals: {location: location}
      else
        render json: {}
      end
    end

    def ship
      if @order.shipment.ship
        @order.update_shipment_state
        render :show
      else
        render json: { errors: @order.errors.full_messages }, status: :bad_request
      end
    end

    def start_shipment
      r = validate
      if r[:ok] == false
        render json: {errors: r[:errors]}, status: :bad_request
        return
      end
      current_account = @current_user.account_user
      if @order.shipment.delivery_man_id == current_account.id
        if @order.shipment.can_start?
          @order.start_shipment
          render :show
        else
          render json: {errors: '状态非法'}, status: :bad_request
        end
      else
        render json: {errors: '此单已被抢,您无权配送'}, status: :bad_request
      end
    end

    def finish_shipment
      r = validate
      if r[:ok] == false
        render json: {errors: r[:errors]}, status: :bad_request
        return
      end
      current_account = @current_user.account_user
      if @order.shipment.delivery_man_id == current_account.id
        if @order.shipment.can_ship?
          @order.ship_shipment
          render :show
        else
          render json: {errors: '状态非法'}, status: :bad_request
        end
      else
        render json: {errors: '此单已被抢,您无权配送'}, status: :bad_request
      end
    end

    def assign_to_self
      r = validate
      if r[:ok] == false
        render json: {errors: r[:errors]}, status: :bad_request
        return
      end
      current_account = @current_user.account_user
      if @order.shipment.delivery_man_id.blank?
        @order.assign_delivery_man(current_account.id)
        head :ok
      else
        render json: {errors: '此单已被抢'}, status: :bad_request
      end
    end

    private
    def order_params
      params.require(:order).permit(:note, :pay_method, shipment: [:address_id, :delivery_zone_id, :delivery_time_id, :delivery_date])
    end

    def validate
      if !@order.is_delivery?
        return {ok: false, errors: '该订单不是外卖订单， 不支持该操作'}
      end
      if !@current_user.is_account_user?
        return {ok: false, errors: '您没有权限操作该订单'}
      end
      return {ok: true}
    end

  end
end
