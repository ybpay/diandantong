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
            @groupon.refund_coupon
            render_empty_success(message: "团购券已退款")
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
