module Ddt
  module Api
    module Admin
      module V1
        class GrouponsController < BaseController
          before_action :set_groupon, only: [:show, :refund]

          def index
            groupons = current_shop.groupons.ransack(params[:q]).result.distinct
            render_paginated(groupons)
          end

          def show
            render_resource(@groupon)
          end

          def refund
            result = @groupon.refund_coupon
            if result
              render_empty_success(message: "团购券已退款")
            else
              render json: { errors: [{ status: 422, detail: "团购券退款失败" }] }, status: :unprocessable_content
            end
          rescue StandardError => e
            render json: { errors: [{ status: 422, detail: e.message }] }, status: :unprocessable_content
          end

          private

          def set_groupon
            @groupon = current_shop.groupons.find(params[:id])
          end
        end
      end
    end
  end
end
