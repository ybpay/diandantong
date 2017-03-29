module Ddt
  module CommonApi
    module V1
      class LabelsController < V1::BaseController
        before_action :set_branch, only: [:service]

        def subtract
          render json: @current_shop.subtract_reasons.map(&:name)
        end

        def gift
          render json: @current_shop.gift_reasons.map(&:name)
        end

        def service
          render json: @branch.waiter_service_items.map(&:name)
        end

        private
          def set_branch
            if params[:branch_id].present?
              @branch = @current_shop.branches.find(params[:branch_id])
            else
              render json: { errors: "branch_id is required" }, status: :bad_request
            end
          end

      end
    end
  end
end
