module Ddt
  class Backend::VouchersController < Backend::BaseController
    check_permission :shop, :voucher_version, :show
    before_action :set_voucher, only: [:show, :edit, :update, :destroy, :refund]
    layout lambda { params[:layout_name]||'ddt/layouts/backend/groupon' }
    def index
      @q = @current_shop.vouchers.ransack(params[:q])
      @vouchers = @q.result.paginate(page: params[:page])
    end

    def show
    end

    def refund
      @voucher.refund_coupon
      redirect_to action: :index
    end

    private
      def set_voucher
        @voucher = @current_shop.vouchers.find(params[:id])
      end

      def voucher_params
        params.require(:voucher).permit(:user_id, :coupon_version_id, :coupon_no, :expires_at, :applied_at)
      end
  end
end
