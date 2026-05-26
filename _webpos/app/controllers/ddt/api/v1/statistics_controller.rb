module Ddt
  module Api
    module V1
      module Webpos
        class StatisticsController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def index
            render json: {
              data: {
                today_orders: @branch.orders.where(placed_at: Time.current.beginning_of_day..Time.current).count,
                today_revenue: @branch.orders.where(placed_at: Time.current.beginning_of_day..Time.current).sum(:total),
                pending_orders: @branch.orders.pending.count
              }
            }
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end
        end
      end
    end
  end
end
