module Ddt
  module CommonApi
    module V1
      module Order
        class OrdersController < V1::BaseController
          check_permission :branch, :order, :show
          def index
            order_params = {placed_at: :desc}
            order_params = {updated_at: :asc} if params[:q] && params[:q][:updated_at_gt].present?
            if params[:q] && params[:q][:delivery_man_id_eq].present?
              order_ids = @current_branch.shipments.where(delivery_man_id: params[:q].delete(:delivery_man_id_eq)).where(created_at: 3.days.ago..Time.now).pluck(:order_id)
              @orders = @current_branch.delivery_orders.includes(:pay_items).order(order_params).where(params[:q]).where(id: order_ids).paginate(page: params[:page], per_page: (params[:per_page] || 20))
            else
              @orders = @current_branch.orders.includes(:pay_items).order(order_params).where(params[:q]).paginate(page: params[:page], per_page: (params[:per_page] || 20))
            end
            fresh_when(@orders)
          end

        end
      end
    end
  end
end
