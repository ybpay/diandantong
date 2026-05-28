module Ddt
  module Backend
    class Payment::PaymentsController < Ddt::Backend::BaseController
      check_permission :shop, :payment, {[:index, :show] => :show}
      include Included::ActsAsModelController
      before_action :set_payment, only: [:show, :edit, :update, :destroy]
      before_action :deal_params, only: [:index]

      def index
        branch_ids = managed_branch_ids
        if current_account.is_boss?
          branch_ids.append(current_shop.abstract_branch.id)
        end
        @q = @current_shop.payments.with_discarded.where(branch_id: branch_ids).order(created_at: :desc).ransack(params[:q])
        @branches = managed_branches
        @payments = @q.result.paginate(page: params[:page])
      end

      def show
      end

      private
      def deal_params
        if params[:q] && params[:q][:order_id_eq].present?
          order_number = params[:q][:order_id_eq]
          order = @current_shop.orders.find_by(number: order_number)
          if order.present?
            params[:q][:order_id_eq] = order.id
          end
        end
      end

      def set_payment
        @payment = @current_shop.payments.find(params[:id])
      end

      def payment_params
        params.require(:payment).permit(:branch_id, :order_id, :amount, :workflow_state, :payment_method_id, :pid, :transation_id)
      end
    end

  end
end
