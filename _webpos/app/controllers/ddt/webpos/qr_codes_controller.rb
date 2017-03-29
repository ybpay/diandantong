module Ddt
  module Webpos
    class QrCodesController < Webpos::BaseController

      def verify_vip_info
        @qr_code_scene = find_qrcode_scene
        if @qr_code_scene.blank?
          @qr_code_scene = create_qrcode_scene
        else
          @qr_code_scene = update_preference(@qr_code_scene)
        end
        render json: to_json(@qr_code_scene)
      end

      def reload_verify_qrcode
        @qr_code_scene = find_qrcode_scene
        @qr_code_scene.destroy if @qr_code_scene.present?
        new_qrcode_scene = create_qrcode_scene
        render json: to_json(new_qrcode_scene)
      end

      private

        def find_qrcode_scene
          Ddt::VerifyVipInfoQrCodeScene.find_by(qr_code_scene_params)
        end

        def create_qrcode_scene
          new_qrcode_scene = Ddt::VerifyVipInfoQrCodeScene.create(qr_code_scene_params)
          update_preference(new_qrcode_scene)
        end

        def update_preference(scene)
          scene.preferred_terminal_id = params[:terminal_id]
          scene.preferred_vip_only = params[:vip_only]
          scene.preferred_account_id = current_account.id
          scene.save
          scene
        end

        def qr_code_scene_params
          {shop_id: @current_shop.id, builtin: true, name: "VERIFY_VIP_#{current_account.id}"}
        end

        def to_json(qr_code_scene)
          {url: qr_code_scene.url.url}
        end
    end
  end
end
