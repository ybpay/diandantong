module Ddt
  module Api
    module Admin
      module V1
        class CouponsController < BaseController
          before_action :set_coupon, only: [:show, :update, :destroy]

          def index
            coupons = current_shop.coupons.ransack(params[:q]).result
            render_paginated(coupons)
          end

          def show
            render_resource(@coupon)
          end

          def create
            coupon = current_shop.coupons.build(coupon_params)
            if coupon.save
              render_resource_created(coupon)
            else
              render_errors(coupon.errors)
            end
          end

          def update
            if @coupon.update(coupon_params)
              render_resource(@coupon)
            else
              render_errors(@coupon.errors)
            end
          end

          def destroy
            @coupon.destroy
            render_empty_success(message: "优惠券已删除")
          end

          private

          def set_coupon
            @coupon = current_shop.coupons.find(params[:id])
          end

          def coupon_params
            params.require(:coupon).permit(:name, :coupon_type, :value, :min_order_amount, :start_at, :end_at, :total_count)
          end
        end
      end
    end
  end
end
