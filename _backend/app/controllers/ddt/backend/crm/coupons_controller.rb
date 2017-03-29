module Ddt
  module Backend
    module Crm
      class CouponsController < Backend::BaseCrmController
        check_permission :shop, :coupon, { [:index, :show] => :show }
        before_action :set_coupon, only: [:show]

        def index
          @q = @current_shop.coupons.ransack(params[:q])
          @coupons = @q.result.paginate(page: params[:page])
        end

        def show
        end

        private
          def set_coupon
            @coupon = @current_shop.coupons.find(params[:id])
          end
      end
    end
  end
end
