module Ddt
  module Backend
    class SaleDataUploaderSettingsController < ::Ddt::Backend::BaseController
      # check_permission :branch, :sale_data_uploader_setting, {show: :show, edit: :update, update: :update}
      before_action :set_sale_data_uploader_setting
      before_action :set_time, only: [:upload_orders, :reupload_orders, :query_orders]
      layout "ddt/layouts/backend/branch"
      def show
      end

      def edit
      end

      def update
        @sale_data_uploader_setting.update(sale_data_uploader_setting_params)
        redirect_to [:backend, @current_shop, @current_branch, @sale_data_uploader_setting]
      end

      def upload_base
        result = @sale_data_uploader_setting.upload_base
        respond_to do |format|
          format.js { render js: "bootbox.alert('#{result ? '上传成功' : '上传失败'}');" }
        end
      end

      def upload_orders
        if @start_time.present? && @end_time.present?
          SaleDataUploaderSetting.delay.upload_orders(@current_branch.id, @start_time, @end_time)
          redirect_to [:backend, @current_shop, @current_branch, @sale_data_uploader_setting], notice: "已提交至上传队列"
        else
          redirect_to [:backend, @current_shop, @current_branch, @sale_data_uploader_setting], alert: "请选择需要上传的订单的时间区间"
        end
      end

      def reupload_orders
        if @start_time.present? && @end_time.present?
          SaleDataUploaderSetting.delay.reupload_orders(@current_branch.id, @start_time, @end_time)
          redirect_to [:backend, @current_shop, @current_branch, @sale_data_uploader_setting], notice: "已提交至补传队列"
        else
          redirect_to [:backend, @current_shop, @current_branch, @sale_data_uploader_setting], alert: "请选择需要补传的订单的时间区间"
        end
      end

      def query_orders
        if @start_time.present? && @end_time.present?
          @result = SaleDataUploaderSetting.query_orders(@current_branch.id, @start_time, @end_time)
          uploaded_count = @result[:uploaded].count
          pending_count = @result[:pending].count
          canceled_count = @result[:canceled].count
          not_find_count = @result[:not_find].count
          render js: "bootbox.alert('已上传#{uploaded_count},待上传#{pending_count},已取消#{canceled_count},未上传#{not_find_count}');"
        else
          render js: "bootbox.alert('请选择需要查询的订单的时间区间');"
        end
      end

      private
      def set_time
        @start_time = params[:uploader][:start_time]
        @end_time = params[:uploader][:end_time]
        @shift_id = params[:uploader][:shift_id]
        if @shift_id.present?
          @shift = Ddt::Shift.find(@shift_id)
          @start_time = @shift.created_at
          @end_time = @shift.closed_at
        end
      end

      def sale_data_uploader_setting_params
        params.require(:sale_data_uploader_setting).permit(:enable, :auto_upload_after_shift)
      end

      def set_sale_data_uploader_setting
        @sale_data_uploader_setting = @current_branch.sale_data_uploader_setting
      end
    end
  end
end
