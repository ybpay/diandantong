module Ddt
  module Api
    module V1
      module Backend
        class GrouponsController < Ddt::Api::V1::BaseController
          before_action :set_shop
          before_action :set_groupon, only: [:show, :refund]

          def index
            groupons = @shop.groupons.ransack(params[:q]).result.distinct
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

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def set_groupon
            @groupon = @shop.groupons.find(params[:id])
          end
        end
      end
    end
  end
end
