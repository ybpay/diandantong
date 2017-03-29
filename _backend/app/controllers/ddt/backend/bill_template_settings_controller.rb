module Ddt
  module Backend
    class BillTemplateSettingsController < Backend::BaseController
      check_permission :branch, :bill_template_setting, { [:show, :preview] => :show, [:edit, :update, :reset, :set_enable] => :update}
      before_action :set_template_name
      before_action :set_bill_template_setting
      layout 'ddt/layouts/backend/branch'
      def show
      end

      def edit
      end

      def update
        @setting.update(setting_params)
        redirect_to backend_shop_branch_bill_template_setting_path(@current_shop, @current_branch, template_name: @template_name)
      end

      def reset
        @setting.reset(@template_name)
        redirect_to backend_shop_branch_bill_template_setting_path(@current_shop, @current_branch, template_name: @template_name)
      end

      def preview
        @bill_in_html = BillTemplateSetting.preview_bill_in_html(@current_branch, @template_name)
        respond_to do |format|
          format.js
        end
      end

      def set_enable
        @setting.set_enable
        redirect_to backend_shop_branch_bill_template_setting_path(@current_shop, @current_branch)
      end

      private
      def setting_params
        params.require(:bill_template_setting).permit(*BillTemplateSetting.all_templates)
      end

      def set_template_name
        @template_name = params[:template_name].try(:to_sym)
        @template_name = BillTemplateSetting.all_templates.first if @template_name.blank?
      end

      def set_bill_template_setting
        @setting = @current_branch.bill_template_setting
      end
    end
  end
end