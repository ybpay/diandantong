# encoding:utf-8
module Ddt
  class Weixin::Order::EatInHallOrdersController < WeixinApplicationController
    include Weixin::BaseOrderController
    include Weixin::BaseOrderCouponController

    before_action :update_deduction, only: [:update]

    def create
      if session[:table_id].present?
        @table = @branch.tables.find(session[:table_id].to_i)
        @cart.set_order_itemables_from_table(@table)
        @cart.note       = order_params[:note]
        @cart.pay_method = order_params[:pay_method]
        if cookies[:guest_num]
          @cart.guest_num = cookies[:guest_num].to_i
        else
          @cart.update_table_info(guest_num: order_params[:guest_num])
        end
        form_contentables = OrderService::FormContentable.init_list(params.fetch(:order,{}).fetch(:form_contents, []))
        @cart.update_form_contents(form_contentables)
        @order = @cart.place
        if @table.current_order_id.present?
          # Ddt::OrderItemable::Adapter.get_from(session).detach(session)
          render json: {custom: true, type: 'Cart:TableTaked', errors: @cart.errors.full_messages, branch_id: @branch.id, order_id: @table.current_order_id}, status: :bad_request
        else
          if @order
            clear_cart
            Ddt::OrderItemable::Adapter.get_from(session).detach(session)
            render json: { order: { id: @order.id }}
          else
            render json: { errors: @cart.errors.full_messages }, status: :bad_request
          end
        end

      else
        render json: {custom: true, type: 'Cart:InvalidJump', branch_id: @branch.id}, status: :bad_request
      end

    end

    def association_domains
      @adapter = Ddt::OrderItemable::Adapter.get_from(session)
      if @adapter.valid?
        @cart = @adapter.get_cart(@branch, @current_user, session)
      else
        @adapter.detach(session)
        render json: {custom: true, type: 'Cart:InvalidJump', branch_id: @branch.id}, status: :bad_request
        return
      end
      @coupons = @current_user.coupons.available.select { |it|
        it.can_apply?(@cart)
      }
      respond_to do |f|
        f.json { render '/ddt/weixin/order/association_domains'}
      end
    end

    def get_order_by_table
      @table = @branch.tables.find(params[:table_id])
      current_order = @table.current_order
      if current_order.present? && current_order.base_user_id == @current_user.id
        @order = current_order
        render :show
      else
        render json: {}
      end
    end

    def call_waiter
      @order.call_waiter(params[:service_name])
      render json: {}
    end

    def request_pay
      @order.request_pay(params[:pay_method_name])
      render json: {}
    end

    def update
      pay_itemable = OrderService::PayItemable.new(name_sym: params[:order][:pay_method], amount: @order.amount_for_pay, shop: @current_shop)
      @order.load_pay_item(pay_itemable)
      if(@order.is_vip_card_pay?)
        @order.change_pay_item_to_paid(@order.pay_items.first)
        render json: {vip_pay: true}
      else
        render json: {vip_pay: false}
      end
    end

    private
    def order_params
      params.require(:order).permit(:note, :pay_method, :guest_num)
    end

    def update_deduction
      set_order if @order.blank?
      credits = params[:order][:credits_deduction].try(:to_i)
      amount  = params[:order][:card_deduction].try(:to_f)
      @order.add_card_deduction(amount)
      @order.add_credits_deduction(credits)
    end

  end
end
