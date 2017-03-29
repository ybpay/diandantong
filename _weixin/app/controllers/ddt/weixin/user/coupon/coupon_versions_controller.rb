module Ddt
  module Weixin
    module User
      module Coupon
        class CouponVersionsController < WeixinApplicationController
          before_action :set_coupon_version, only: [:show, :exchange]


          def index
            @q = @current_shop.coupon_versions.usable.ransack(params[:q])
            @coupon_versions = @q.result
          end

          def show
          end

          def exchange
            if params[:num] && params[:note]
              result = @coupon_version.exchange_by(@current_user, params[:num].to_i, params[:note])
              if result
                render json: {}
              else
                render json: {errors: @coupon_version.errors.full_messages}, status: :bad_request
              end
            end
          end

          private

            def set_coupon_version
              @coupon_version = @current_shop.coupon_versions.find(params[:id])
            end

        end
      end
    end
  end
end
