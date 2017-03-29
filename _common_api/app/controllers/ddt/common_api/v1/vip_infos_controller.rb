module Ddt
  module CommonApi
    module V1
      class VipInfosController < V1::BaseController
        def get_by_scan_code
          @vip_info = @current_shop.vip_infos.get_by_scan_code(params[:scan_code])
          if @vip_info.present?
            render :show
          else
            render json: { errors: "付款码不正确或已过期" }, status: :bad_request
          end
        end
      end
    end
  end
end
