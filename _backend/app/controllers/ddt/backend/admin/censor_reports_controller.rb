#encoding: utf-8
module Ddt
  module Backend
    class Admin::CensorReportsController < Backend::BaseAdminController
      before_action :set_censor_report, only: [:show, :confirm, :reject, :ban, :cancel_ban]
      def index
        @q = Ddt::CensorReport.all.ransack(params[:q])
        @censor_reports = @q.result.paginate(page: params[:page], :per_page => 25)
      end

      def show
      end

      def confirm
        audit { @censor_report.confirm}
      end

      def reject
        audit { @censor_report.reject}
      end

      def ban
        audit { @censor_report.shop.update(is_ban: true)}
      end

      def cancel_ban
        audit { @censor_report.shop.update(is_ban: false)}
      end

      private
      def set_censor_report
        @censor_report = Ddt::CensorReport.find(params[:id])
      end

      def audit
        success = false
        if success = yield
          @censor_report.update(
              :auditor => current_account,
              :audited_at => Time.current
          )
        end
        render :reset
      end
    end
  end
end