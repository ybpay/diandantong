module Ddt
  module Api
    module V1
      module Backend
        class CreditsSettingsController < Ddt::Api::V1::BaseController
          before_action :set_shop

          def show
            credits_setting = @shop.credits_setting
            render_resource(credits_setting)
          end

          def update
            credits_setting = @shop.credits_setting
            if credits_setting.update(credits_setting_params)
              render_resource(credits_setting)
            else
              render_errors(credits_setting.errors)
            end
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def credits_setting_params
            params.require(:credits_setting).permit(:exchange_radio)
          end
        end
      end
    end
  end
end
