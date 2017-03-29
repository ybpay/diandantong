module Ddt
  module Backend
    module Crm
      class CreditsSettingsController < Backend::BaseCrmController
        check_permission :shop, :credits_setting, {show: :show, update: :update}
        before_action :set_credits_setting

        def show
        end

        def update
          if @credits_setting.update(credits_setting_params)
            render :show
          else
            render json: { errors: @credits_setting.errors.full_messages }, status: :bad_request
          end
        end

        private
          def set_credits_setting
            @credits_setting = @current_shop.credits_setting
          end

          def credits_setting_params
            params.require(:credits_setting).permit(:exchange_radio, :auto_clear_credits)
          end
      end
    end
  end
end
