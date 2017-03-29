#encoding:utf-8
module Ddt
  module Backend
    class AccessDenyException < Exception
    end

    class Admin::WithdrawsController < Ddt::Backend::BaseAdminController
      before_action :set_withdraw, only: [:complete, :cancel]
      before_action :check_privilege

      def index
        @q = Ddt::Withdraw.ransack(params[:q])
        @withdraws = @q.result.order(:created_at => :desc).paginate(page: params[:page], per_page: 20)
      end

      def complete
        if @withdraw.pending?
          @withdraw.complete!
          success = true
        end
        render :json => {
                   success: success,
                   state: @withdraw.state,
                   state_name: @withdraw.state_name
               }
      end

      def cancel
        if @withdraw.pending?
          @withdraw.cancel!
          success = true
        end
        render :json => {
                   success: success,
                   state: @withdraw.state,
                   state_name: @withdraw.state_name
               }
      end

      private
      def set_withdraw
        @withdraw = Ddt::Withdraw.find(params[:id])
      end

      def check_privilege
        raise AccessDenyException unless @current_account.is_admin?
      end

    end
  end
end