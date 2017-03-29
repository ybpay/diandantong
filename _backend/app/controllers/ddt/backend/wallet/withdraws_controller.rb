module Ddt
  module Backend
    module Wallet
      class WithdrawsController < Ddt::Backend::BaseController
        check_permission :shop, :collection_wallet, { index: :show, [:new, :create] => :withdraw}
        layout 'ddt/layouts/backend/alipay_method'
        before_action :set_wallet

        def index
          @q = @wallet.withdraws.order(created_at: :desc).ransack(params[:q])
          @withdraws = @q.result.paginate(page: params[:page], per_page: 20)
        end

        def new
          alipay = @current_shop.alipay_method
          @withdraw = @wallet.withdraws.new(
            alipay_account_id: alipay.preferred_withdraw_account_id,
            alipay_account_name: alipay.preferred_withdraw_account_name
          )
        end

        def create
          @withdraw = @wallet.withdraw(withdraw_params)
          unless @withdraw.errors.present?
            flash[:success] = '提款成功'
            redirect_to [:backend, @current_shop, :collection_logs]
          else
            flash[:error] = @withdraw.errors.full_messages.join(',')
            render :new
          end
        end

        private
        def set_wallet
          @wallet = @current_shop.collection_wallet
        end

        def withdraw_params
          params.require(:withdraw).permit(:alipay_account_id, :alipay_account_name, :amount, :note)
        end
      end
    end
  end
end