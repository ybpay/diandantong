module Ddt
  module CommonApi
    module V1
      class BaseCouponsController < V1::BaseController
        before_action :set_base_coupon, only: [:exchange]

        def find_by_code
          @coupon = @current_shop.coupons.actived.available.includes(:exchange_code).where("ddt_exchange_codes.code = ?", params[:code]).references("ddt_exchange_codes").first
          if @coupon.present?
            if @coupon.can_use_in_branch? @current_branch
              render :show
            else
              render json: { errors: "该优惠券不能用于该门店" }, status: :bad_request
            end
          else
            render json: { errors: "未找到优惠券" }, status: :bad_request
          end
        end

        def exchange
          @base_coupon.exchange
          head :ok
        end

        private

          def set_base_coupon
            @base_coupon = @current_shop.base_coupons.find params[:id]
          end

      end
    end
  end
end
