module Ddt
  module Api
    module V1
      module Webpos
        class VipInfosController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def index
            vip_infos = @branch.vip_infos.ransack(params[:q]).result
            render_paginated(vip_infos)
          end

          def show
            vip_info = @branch.vip_infos.find(params[:id])
            render_resource(vip_info)
          end

          def create
            vip_info = @branch.vip_infos.build(vip_info_params)
            if vip_info.save
              render_resource_created(vip_info)
            else
              render_errors(vip_info.errors)
            end
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def vip_info_params
            params.require(:vip_info).permit(:name, :phone, :vip_level_id, :note)
          end
        end
      end
    end
  end
end
