
module Ddt
  module CommonApi
    module V1
      class NotificationReceiveSettingsController < V1::BaseController

        def show
          @notification_receive_setting = @current_account.notification_receive_setting
          render :show
        end

        def update
          @notification_receive_setting = @current_account.notification_receive_setting
          if @notification_receive_setting.update(notification_receive_setting_params)
            render :show
          else
            render json: {errors: @notification_receive_setting.errors.full_messages}, status: :bad_request
          end
        end

        private 
        def notification_receive_setting_params
          params.require(:notification_receive_setting).permit(*NotificationReceiveSetting.all_settings)
        end


      end
    end
  end
end
