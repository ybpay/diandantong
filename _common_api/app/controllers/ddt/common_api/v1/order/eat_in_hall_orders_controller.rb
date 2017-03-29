module Ddt
  module CommonApi
    module V1
      module Order
        class EatInHallOrdersController < V1::BaseController
          include V1::BaseOrderController
          include V1::BaseOrderChangeController
          check_permission :branch, :eat_in_hall_order, {
              create: :create,
              change_table: :change_table,
              merge_table: :merge_table,
              move_itemable: :move_itemable,
              update_guest_num: :update_guest_num,
          }, only: [:create, :change_table, :merge_table, :update_guest_num, :move_itemable]
          #
          # params: {
          #   track_from: FromWebpos || FromApp,
          #   terminal_id: xxx,
          #
          #   cart: {
          #     table_id: 1,
          #     guest_num: n,
          #     line_items_attributes: [ {:itemable_type, :itemable_id, :quantity}]
          #     note: 'note'
          #   },
          #   is_local_printed: true,
          #   is_money_display: true
          # }
          #
          def create
            @table = @current_branch.tables.find(params[:cart][:table_id])
            line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
            cart = OrderService::Cart::EatInHall.new(base_cart_params.merge(
                table: @table,
                guest_num: params[:cart][:guest_num] || @table.guest_num || 1,
                line_itemables: line_itemables,
                note: params[:cart][:note],
            ))
            @order = cart.place
            if @order
              if @order.is_local_printed
                render json: { bill: order_bill(@order, is_product_bill: true, is_money_display: params[:is_money_display])}
              else
                render :show
              end
            else
              render json: {errors: cart.errors.full_messages}, status: :bad_request
            end
          end

          #
          # params{ :table_id }
          #
          def change_table
            @table = @current_branch.tables.find(params[:table_id])
            if @order.change_table(@table)
              render :show
            else
              render json: { errors: @order.errors.full_messages }, status: :bad_request
            end
          end

          #
          # params{ :table_id }
          #
          def merge_table
            @table = @current_branch.tables.find(params[:table_id])
            if @order.merge_table(@table)
              render :show
            else
              render json: { errors: @order.errors.full_messages }, status: :bad_request
            end
          end

          #
          # params: {
          #   table_id
          #   moveables: [{:line_item_id, :quantity}]
          # }
          #
          def move_itemable
            @table = @current_branch.tables.find(params[:table_id])
            moveables = OrderService::Moveable.init_list(params[:moveables], order: @order)
            if @order.move_itemable(@table, moveables)
              render :show
            else
              render json: { errors: @order.errors.full_messages }, status: :bad_request
            end
          end

          #
          # params{ :service_item }
          #
          def call_waiter
            @order.call_waiter(params[:service_item])
            render json: {}
          end

          def update_guest_num
            @order.update_guest_num(params[:guest_num])
            render :show
          end
          #
          # params{ :pay_method_name}
          #
          def request_pay
            @order.request_pay(params[:pay_method_name])
            render json: {}
          end

        end
      end
    end
  end
end
