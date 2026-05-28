module Ddt
  module Api
    module Admin
      module V1
        class VipInfosController < BaseController
          before_action :set_vip_info, only: [:show, :update]

          def index
            vip_infos = current_shop.vip_infos.ransack(params[:q]).result
            render_paginated(vip_infos)
          end

          def show
            render_resource(@vip_info)
          end

          def create
            vip_info = current_shop.vip_infos.build(vip_info_params)
            if vip_info.save
              render_resource_created(vip_info)
            else
              render_errors(vip_info.errors)
            end
          end

          def update
            if @vip_info.update(vip_info_params)
              render_resource(@vip_info)
            else
              render_errors(@vip_info.errors)
            end
          end

          private

          def set_vip_info
            @vip_info = current_shop.vip_infos.find(params[:id])
          end

          def vip_info_params
            params.require(:vip_info).permit(:name, :phone, :vip_level_id, :pay_password)
          end
        end
      end
    end
  end
end
