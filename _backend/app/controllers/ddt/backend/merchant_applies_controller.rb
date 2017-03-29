module Ddt
  class Backend::MerchantAppliesController < Backend::BaseController
    check_permission :shop, :merchant_apply, :manage
    before_action :set_merchant_apply, only: [:show, :confirm, :reject]

    def index
      @q = @current_shop.merchant_applies.ransack(params[:q])
      @merchant_applies = @q.result.paginate(page: params[:page])
    end

    def show

    end

    def confirm
      @merchant_apply.confirm!
      respond_to do |format|
        format.js { render '/ddt/backend/merchant_applies/reset_table_tr'}
      end
    end

    def reject
      @merchant_apply.reject!
      respond_to do |format|
        format.js { render '/ddt/backend/merchant_applies/reset_table_tr'}
      end
    end

    private
    def set_merchant_apply
      @merchant_apply = @current_shop.merchant_applies.find(params[:id])
    end
  end
end
