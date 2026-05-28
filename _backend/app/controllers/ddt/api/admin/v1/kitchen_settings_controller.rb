module Ddt
  module Api
    module Admin
      module V1
        class KitchenSettingsController < BaseController
          def show
            branch = current_shop.branches.find(params[:branch_id]) if params[:branch_id]
            kitchen_setting = (branch || current_shop.branches.first)&.kitchen_setting
            render_resource(kitchen_setting)
          end

          def update
            branch = current_shop.branches.find(params[:branch_id]) if params[:branch_id]
            kitchen_setting = (branch || current_shop.branches.first).kitchen_setting
            if kitchen_setting.update(kitchen_setting_params)
              render_resource(kitchen_setting)
            else
              render_errors(kitchen_setting.errors)
            end
          end

          private

          def kitchen_setting_params
            params.require(:kitchen_setting).permit(:warning_wait_minitue)
          end
        end
      end
    end
  end
end
