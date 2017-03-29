#encoding: utf-8
module Ddt
  class Common::VerifyVipInfoQrCodeScenesController < CommonApplicationController
    before_filter :set_qr_code_scene, only: [:show, :verify]
    skip_before_action :validate_user_info

    def show
      unless ddt_app?
        validate_user_info

        if @qr_code_scene.preferred_vip_only
          # 结算里面的绑定会员， 此时只有是vip的才可绑定
          if @current_user.vip?
            Ddt::WebposNotify.verify_vip_info_scan_success(@qr_code_scene)
          else
            @user_vip_info_url = Ddt::LinkResource.new(shop: @current_shop).user_vip_info_url
            @message = "您还不是vip会员。无法进行该操作"
          end
        else
          # 会员管理里面的绑定微信
          Ddt::WebposNotify.verify_vip_info_scan_success(@qr_code_scene)
        end


        render "ddt/weixin/verify/show"
      else
      end

    end

    def verify
      validate_user_info
      @qr_code_scene.scan_by(@current_user)
      vip_info_id = @current_user.vip_info
      @vip_info = @current_shop.vip_infos.find(vip_info_id)
      if @vip_info.present?
        Ddt::WebposNotify.verify_vip_info(@qr_code_scene, @vip_info)
        @success = true
      else
        @success = false
      end
      render "ddt/weixin/verify/show"
    end

    private
    def set_qr_code_scene
      @qr_code_scene = @current_shop.verify_vip_info_qr_code_scenes.friendly.find(params[:id])
    end

  end
end
