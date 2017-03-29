module Ddt
  module Webpos
    module Order
      class OrdersController < Webpos::BaseController
        include Ddt::BatchChangeOrderState
        before_action :set_order, only: [:show]
        before_action :set_orders, only: [:index]
        check_permission :branch, :order, { [:index, :show, :pending_counts] => :show, batch_change_state: :batch_change_state}

        def index
          @orders = @orders.includes(:pay_items).order(placed_at: :desc).where(params[:q]).paginate(page: params[:page], per_page: (params[:per_page] || 20))
          fresh_when(@orders)
        end

        def show
        end

        def batch_change_state
          batch_change_order_state do |errors|
            if errors.present?
              render json: {errors: errors}, status: :bad_request
            else
              render json: {}
            end
          end
        end

        def pending_counts
          orders = @current_branch.orders.pending
          render json: {
            :'Ddt::EatInHallOrder'   => orders.eat_in_hall.count,
            :'Ddt::DeliveryOrder'    => orders.delivery.count,
            :'Ddt::FastfoodOrder'    => orders.fastfood.count,
            :'Ddt::ReservationOrder' => orders.reservation.count,
            :'Ddt::PaymentOrder'     => orders.payment.count,
            :'Ddt::GrouponOrder'     => orders.groupon.count,
            :'Ddt::RechargeOrder'    => orders.recharge.count,
          }
        end

        private
        def set_order
          @order = @current_branch.orders.includes(:line_items, :adjustments, :form_contents, :pay_items).find(params[:id])
        end

        def set_orders
          @orders = @current_branch.orders.includes_none
        end

      end
    end
  end
end
