module Ddt
  module Api
    module V1
      module Backend
        class NotificationSettingsController < Ddt::Api::V1::BaseController
          before_action :set_shop
          before_action :set_account
          before_action :set_notification_setting

          def show
            render_resource(@notification_receive_setting)
          end

          def update
            if @notification_receive_setting.update(setting_params)
              render_resource(@notification_receive_setting)
            else
              render_errors(@notification_receive_setting.errors)
            end
          end

          private

          def set_shop
            @shop = current_account.is_admin? ? Ddt::Shop.find(params[:shop_id]) : current_account.shop
          end

          def set_account
            @account = @shop.accounts.find(params[:account_id])
          end

          def set_notification_setting
            @notification_receive_setting = @account.notification_receive_setting
          end

          def setting_params
            params.require(:notification_receive_setting).permit(*Ddt::NotificationReceiveSetting.all_settings)
          end
        end
      end
    end
  end
end
