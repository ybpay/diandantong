module Ddt
  module Api
    module V1
      module Backend
        class CouponVersionsController < Ddt::Api::V1::BaseController
          before_action :set_shop
          before_action :set_coupon_version, only: [:show, :update, :destroy]

          def index
            coupon_versions = @shop.coupon_versions.ransack(params[:q]).result
            render_paginated(coupon_versions)
          end

          def show
            render_resource(@coupon_version)
          end

          def create
            coupon_version = @shop.coupon_versions.build(coupon_version_params)
            if coupon_version.save
              render_resource_created(coupon_version)
            else
              render_errors(coupon_version.errors)
            end
          end

          def update
            if @coupon_version.update(coupon_version_params)
              render_resource(@coupon_version)
            else
              render_errors(@coupon_version.errors)
            end
          end

          def destroy
            @coupon_version.destroy
            render_empty_success(message: "优惠券版本已删除")
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def set_coupon_version
            @coupon_version = @shop.coupon_versions.find(params[:id])
          end

          def coupon_version_params
            params.require(:coupon_version).permit(
              :name, :coupon_type, :norminal_value, :coupon_min_usable_amount,
              :total_count, :per_user_limit, :start_at, :end_at,
              :branch_id, :description
            )
          end
        end
      end
    end
  end
end
