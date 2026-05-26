module Ddt
  module Api
    module V1
      module Weixin
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

          private

          def set_branch
            @branch = current_shop&.branches&.find(params[:branch_id]) || Ddt::Branch.find(params[:branch_id])
          end
        end
      end
    end
  end
end
