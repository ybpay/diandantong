module Ddt
  module Webpos
    module Order
      class EatInHallOrdersController < Webpos::BaseController
        include Webpos::BaseOrderController
        include Webpos::AntiSettlementController
        include Webpos::BaseOrderChangeController

        check_permission :branch, :eat_in_hall_order, {
          create: :create,
          change_table: :change_table,
          merge_table: :merge_table,
          move_itemable: :move_itemable,
          bind_reservation_order: :bind_reservation_order,
          trace_waiter: :trace_waiter,
          allow_selfpay: :allow_selfpay,
          update_guest_num: :update_guest_num,
          change_weight: :change_line_item_weight,
        }, only: [:create, :change_table, :merge_table, :move_itemable, :bind_reservation_order, :trace_waiter, :allow_selfpay, :update_guest_num, :change_weight]

        def create
          @table = @current_branch.tables.find(params[:cart][:table_id])
          line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
          cart = OrderService::Cart::EatInHall.new(base_cart_params.merge(
            line_itemables: line_itemables,
            table: @table,
            note: params[:note],
          ))
          @order = cart.place
          if @order
            if @order.is_local_printed
              render json: { bill: order_bill(@order, is_product_bill: true)}
            else
              render :show
            end
          else
            render json: {errors: cart.errors.full_messages}, status: :bad_request
          end
        end

        def change_table
          @table = @current_branch.tables.find(params[:table_id])
          if @order.change_table(@table)
            render json: {}, status: :ok
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def merge_table
          @table = @current_branch.tables.find(params[:table_id])
          if @order.merge_table(@table)
            render json: {}, status: :ok
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def move_itemable
          @table = @current_branch.tables.find(params[:table_id])
          moveables = OrderService::Moveable.init_list(params[:moveables], order: @order)
          if @order.move_itemable(@table, moveables)
            render json: {}, status: :ok
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def bind_reservation_order
          reservation_order = @current_branch.reservation_orders.find(params[:reservation_order_id])
          if reservation_order.blank?
            render json: { errors: "当前只允许选择预订订单，请选择预订订单进行绑定"}, status: :bad_request
            return
          end
          @order.bind_reservation_order(reservation_order)
          if @order.errors.empty?
            render :show
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def trace_waiter
          @order.waiter_id = params[:waiter_id]
          if @order.save
            render :show
          else
            render json: {errors: ['设置失败']}, status: :bad_request
          end
        end

        def allow_selfpay
          @order.allow_selfpay
          render :show
        end

        def update_guest_num
          @order.update_guest_num(params[:guest_num])
          render :show
        end

        def change_weight
          @order.change_line_item_weight(params[:line_item_id].to_i, params[:weight].to_f)
          if @order.errors.empty?
            render :show
          else
            render json: { errors: @order.errors.full_messages}, status: :bad_request
          end
        end

      end
    end
  end
end
