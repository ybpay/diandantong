module Ddt
  module Api
    module Admin
      module V1
        class CreditsSettingsController < BaseController
          def show
            render_resource(current_shop.credits_setting)
          end

          def update
            credits_setting = current_shop.credits_setting
            if credits_setting.update(credits_setting_params)
              render_resource(credits_setting)
            else
              render_errors(credits_setting.errors)
            end
          end

          private

          def credits_setting_params
            params.require(:credits_setting).permit(:exchange_radio)
          end
        end
      end
    end
  end
end
