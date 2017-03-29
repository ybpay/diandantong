#encoding: utf-8
module Ddt
  module Backend
    class Admin::QrCodeAssignLogsController < Ddt::Backend::BaseAdminController
      before_action :set_qr_code_assign_log, only: [:show, :edit, :update, :destroy]

      def index
        @q = Ddt::QrCodeAssignLog.ransack(params[:q])
        @qr_code_assign_logs = @q.result.paginate(page: params[:page])
      end

      def show
      end

      def new
        @qr_code_assign_log = Ddt::QrCodeAssignLog.new
      end

      

      def create
        @qr_code_assign_log = Ddt::QrCodeAssignLog.new(qr_code_assign_log_params)

        if @qr_code_assign_log.save
          redirect_to [:backend, @qr_code_assign_log], notice: "#{t('activerecord.models.ddt/qr_code_assign_log')} 创建成功."
        else
          render :new
        end
      end


      private
        def set_qr_code_assign_log
          @qr_code_assign_log = Ddt::QrCodeAssignLog.find(params[:id])
        end

        def qr_code_assign_log_params
          params.require(:qr_code_assign_log).permit(:count, :note, :shop_id, :branch_id)
        end
    end
  end
end