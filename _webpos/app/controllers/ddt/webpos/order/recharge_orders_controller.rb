module Ddt
  module Webpos
    module Order
      class RechargeOrdersController < Webpos::BaseController
        include Ddt::Webpos::OrderBill
        respond_to :json
        before_action :set_order_type
        before_action :set_order, except: [:create]
        check_permission :branch, :recharge_order, {
          [:show, :bill] => :show,
          cancel: :cancel,
          create: :create,
          [:create_pay_items, :clear_pay_items, :pay_all_pay_items] => :settle,
          init_refund: :init_refund
        }

        def show
          fresh_when(@order)
        end

        def cancel
          @order.cancel(params[:cancel_reason]) if @order.can_cancel?
          if @order.errors.present?
            render status: :bad_request, json: { errors: @order.errors.full_messages }
          else
            render :show
          end
        end

        def bill
          append_options = {}
          if params[:options].present?
            append_options = JSON.parse(params[:options]).symbolize_keys
          end
          render json: { bill: order_bill(@order, {is_paid_bill: @order.is_paid?}.merge(append_options)) }
        end

        def create
          line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
          vip_info = current_shop.vip_infos.find(params[:cart][:vip_info_id])
          @cart = OrderService::Cart::Recharge.new(base_cart_params.merge(
            line_itemables: line_itemables,
            vip_info: vip_info
          ))
          @order = @cart.place
          if @order
            render json: { order_id: @order.id, type_str: @order.type_str }
          else
            render json: {errors: @cart.errors.full_messages}, status: :bad_request
          end
        end

        def create_pay_items
          @order.is_local_printed = params[:is_local_printed]
          pay_itemables = OrderService::PayItemable.init_list(params[:pay_items], shop: @current_shop)
          if @order.create_pay_items(pay_itemables)
            render :show
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def clear_pay_items
          if @order.clear_pay_items
            render :show
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def pay_all_pay_items
          if @order.pay_all_pay_items
            render :show
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def init_refund
          if @order.can_init_refund?
            @order.init_refund
            if @order.errors.blank?
              render :show
            else
              render json: { errors: @order.errors.full_messages }, status: :bad_request
            end
          end
        end

        private

        def set_order_type
          @order_type = controller_name.gsub('_orders', '')
        end

        def set_order
          if %W[show].include? action_name
            @order = Ddt::OrderService::Orders.includes(:line_items, :adjustments, :form_contents, :pay_items).find(params[:id])
          else
            @order = @current_branch.orders.send(@order_type).find(params[:id])
          end
          @order.operator = current_account
          @order.terminal_id = @terminal_id
        end

        def base_cart_params
          {
            branch: @current_branch,
            waiter: current_account,
            track_from: @track_from,
            is_local_printed: params[:is_local_printed],
            terminal_id: @terminal_id
          }
        end

      end
    end
  end
end
