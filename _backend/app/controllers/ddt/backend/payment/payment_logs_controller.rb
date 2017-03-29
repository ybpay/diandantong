module Ddt
  module Backend
    class Payment::PaymentLogsController < Ddt::Backend::BaseController
      check_permission :shop, :payment_log, {index: :show}

      def index
        @q = @current_shop.payment_logs.where(branch_id: managed_branch_ids).ransack(params[:q])
        @branches = managed_branches
        @payment_logs = @q.result.order(id: :desc).paginate(page: params[:page])
      end

    end
  end
end
