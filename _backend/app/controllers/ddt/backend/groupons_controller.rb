module Ddt
  class Backend::GrouponsController < Backend::BaseController
    check_permission :shop, :groupon_version, :show
    before_action :set_groupon, only: [:show, :edit, :update, :destroy, :refund]
    layout 'ddt/layouts/backend/groupon'

    def index
      @q = @current_shop.groupons.ransack(params[:q])
      @groupons = @q.result(distinct: true).paginate(page: params[:page])
    end

    def show
    end

    def refund
      @groupon.refund_coupon
      redirect_to action: :index
    end

    private
      def set_groupon
        @groupon = @current_shop.groupons.find(params[:id])
      end
  end
end
