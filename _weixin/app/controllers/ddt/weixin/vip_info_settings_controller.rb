module Ddt
  class Weixin::VipInfoSettingsController < WeixinApplicationController

    def show
      @setting = @current_shop.vip_info_setting
      render json: @setting.as_json
    end
  end
end
