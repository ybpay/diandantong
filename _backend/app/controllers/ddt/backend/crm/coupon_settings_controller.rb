module Ddt
  module Backend
    module Crm
      class CouponSettingsController < Backend::BaseCrmController
        before_action :set_coupon_setting

        def show
        end

        def update
          if @coupon_setting.update(coupon_setting_params)
            render :show
          else
            render json: { errors: @coupon_setting.errors.full_messages }, status: :bad_request
          end
        end

        private
          def set_coupon_setting
            @coupon_setting = @current_shop.coupon_setting
          end

          def coupon_setting_params
            params.require(:coupon_setting).permit(:enable_expired_notify, :expired_notify_in_advance_days)
          end
      end
    end
  end
end
