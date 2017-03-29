module Ddt
  module CommonApi
    module V1
      module Order
        class FastfoodOrdersController < V1::BaseController
          include V1::BaseOrderController
          include V1::BasePayItemController

          check_permission :branch, :fastfood_order, {
              create: :create,
              create_and_pay: :create_and_pay,
          }, only: [:create_and_pay, :create]

          # params: {
          #   track_from: FromWebpos || FromApp,
          #   terminal_id: xxx,
          #   cart: {
          #     food_number: '001',
          #     line_items_attributes: [ {:itemable_type, :itemable_id, :quantity}],
          #     note: 'note',
          #   }
          # }
          def create
            line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
            @cart = OrderService::Cart::Fastfood.new(base_cart_params.merge(
              line_itemables: line_itemables,
              note: params[:cart][:note],
              food_number: params[:cart][:food_number],
            ))
            @order = @cart.place
            if @order
              render json: { order_id: @order.id, type_str: @order.type_str }
            else
              render json: {errors: @cart.errors.full_messages}, status: :bad_request
            end
          end

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
          #   is_money_display: true，
          #
          #   pay_number: 支付码，相当于 dynamic_id
          #
          # }
          #
          def create_and_pay
            begin
              pay_item_params = to_pay_item_params
            rescue => e
              render json: {errors: e}, status: :bad_request
              return
            end

            internal_create_order
            if @order.blank?
              if @cart.errors.present?
                render json: { errors: @cart.errors.full_messages }, status: :bad_request
              else
                render json: { errors: '订单没创建成功' }, status: :bad_request
              end
              return
            end

            if @order.errors.present?
              render json: { errors: @order.errors.full_messages }, status: :bad_request
              return
            end

            pay_item_params[:amount] = @order.total
            pay_items = [pay_item_params]

            pay_itemables = OrderService::PayItemable.init_list(pay_items, shop: @current_shop)
            unless @order.create_pay_items(pay_itemables)
              render json: {errors: '支付参数不正确'}, stauts: :bad_request
              return
            end

            internal_pay_online
            render :show
          end

          private

          def internal_create_order
            line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
            @cart = OrderService::Cart::Fastfood.new(base_cart_params.merge(
                line_itemables: line_itemables,
                note: params[:cart][:note],
                food_number: params[:cart][:food_number],
            ))
            @order = @cart.place
          end
        end
      end
    end
  end
end
