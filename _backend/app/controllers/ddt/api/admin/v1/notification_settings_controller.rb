module Ddt
  module Api
    module Admin
      module V1
        class NotificationSettingsController < BaseController
          before_action :set_account

          def show
            render_resource(@account.notification_receive_setting)
          end

          def update
            setting = @account.notification_receive_setting
            if setting.update(setting_params)
              render_resource(setting)
            else
              render_errors(setting.errors)
            end
          end

          private

          def set_account
            @account = current_shop.accounts.find_by(id: params[:account_id]) || current_account
          end

          def setting_params
            params.require(:notification_receive_setting).permit(*Ddt::NotificationReceiveSetting.all_settings)
          end
        end
      end
    end
  end
end
