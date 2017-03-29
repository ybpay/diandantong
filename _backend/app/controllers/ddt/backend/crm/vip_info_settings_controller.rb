module Ddt
  module Backend
    module Crm
      class VipInfoSettingsController < Backend::BaseCrmController
        # check_permission :shop, :vip_info_setting
        before_action :set_vip_info_setting

        def show
        end

        def update
          if @vip_info_setting.update(vip_info_setting_params)
            render :show
          else
            render json: { errors: @vip_info_setting.errors.full_messages }, status: :bad_request
          end
        end

        private
          def set_vip_info_setting
            @vip_info_setting = @current_shop.vip_info_setting
          end

          def vip_info_setting_params
            params.require(:vip_info_setting).permit(*Ddt::VipInfoSetting.config_columns)
          end
      end
    end
  end
end
