module Ddt
  module Backend
    module Branch
      class PrintSettingsController < ::Ddt::Backend::BaseController
        check_permission :branch, :print_setting, {show: :show, edit: :update, update: :update}
        before_action :set_print_setting
        layout "ddt/layouts/backend/branch"
        def show
        end

        def edit
        end

        def update
          update_params = print_setting_params
          is_auto_confirm = update_params.delete(:is_auto_confirm)
          @current_branch.update_column(:is_auto_confirm, is_auto_confirm)
          @print_setting.update(update_params)
          redirect_to [:backend, @current_shop, @current_branch, @print_setting]
        end

        private
        def print_setting_params
          params.require(:print_setting).permit(:is_auto_confirm, :is_webpos_print_eatinhall_order_when_place, :is_current_print_when_place, :merge_same_item)
        end

        def set_print_setting
          @print_setting = @current_branch.print_setting
        end
      end
    end
  end
end
