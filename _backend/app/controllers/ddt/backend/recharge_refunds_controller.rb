module Ddt
  module Backend
    class RechargeRefundsController < Ddt::Backend::BaseController
      check_permission :shop, :recharge_refund
      before_action :set_recharge_refund, except: [:index]

      def index
        @q = @current_shop.recharge_refunds.ransack(params[:q])
        @recharge_refunds = @q.result(distinct: true).paginate(page: params[:page])
      end

      def complete
        @recharge_refund.complete if @recharge_refund.can_complete?
        #审核人，审核时间
        @recharge_refund.update(reviewer: current_account, review_time: Time.now)
        respond_to do |format|
          format.js{ render :update }
        end
      end

      def cancel
        @recharge_refund.cancel  if @recharge_refund.can_cancel?
         #审核人，审核时间
        @recharge_refund.update(reviewer: current_account, review_time: Time.now)
        respond_to do |format|
          format.js{ render :update }
        end
      end

      private
      def set_recharge_refund
        @recharge_refund = @current_shop.recharge_refunds.find(params[:id])
      end
    end
  end
end