module Ddt
  module Api
    module V1
      module Backend
        class KitchenSettingsController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def show
            kitchen_setting = @branch.kitchen_setting
            render_resource(kitchen_setting)
          end

          def update
            kitchen_setting = @branch.kitchen_setting
            if kitchen_setting.update(kitchen_setting_params)
              render_resource(kitchen_setting)
            else
              render_errors(kitchen_setting.errors)
            end
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def kitchen_setting_params
            params.require(:kitchen_setting).permit(:warning_wait_minitue)
          end
        end
      end
    end
  end
end
