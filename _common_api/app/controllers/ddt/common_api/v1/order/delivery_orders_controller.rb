
module Ddt
  module CommonApi
    module V1
      module Order
        class DeliveryOrdersController < V1::BaseController
          include V1::BaseOrderController
          include V1::BaseOrderChangeController
          check_permission :branch, :delivery_order, {
            assign_delivery_man: :assign_delivery_man,
            start_delivery: :start_shipment,
            finish_delivery: :finish_shipment,
          }, only: [:assign_delivery_man, :start_delivery, :finish_delivery]

          def assign_delivery_man
            if @order.is_delivery?
              unless @order.delivery_man.present?
                @order.assign_delivery_man(current_account.id)
                render :show
              else
                render json: {errors: '此单已被抢'}, status: :bad_request
              end
            else
              render json: {errors: '订单类型必须是外送订单'}, status: :bad_request
            end
          end

          def start_delivery
            if @order.is_delivery?
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
            else
              render json: {errors: '订单类型必须是外送订单'}, status: :bad_request
            end
          end

          def finish_delivery
            if @order.is_delivery?
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
            else
              render json: {errors: '订单类型必须是外送订单'}, status: :bad_request
            end
          end
        end
      end
    end
  end
end
