module Ddt
  module Weixin
    module User
      module Coupon
        class CouponsController < WeixinApplicationController
          respond_to :json
          before_action :set_collection, only: [:index]
          before_action :set_coupon, only: [:show]
          def index
            @coupons = @collection.paginate(page: params[:page], per_page: params[:per_page] || 8)
          end

          def show
          end

          def status
            render json: {
              available: @current_user.base_coupons.available.count,
              applied: @current_user.base_coupons.applied.count,
              expired: @current_user.base_coupons.expired.count,
              refund: @current_user.base_coupons.refund.count
            }
          end

          private
          def set_collection
            if params[:state]
              case params[:state].to_sym
              when :available then @collection = @current_user.coupons.available
              when :applied   then @collection = @current_user.coupons.applied
              when :expired   then @collection = @current_user.coupons.expired
              when :refund    then @collection = @current_user.coupons.refund
              end
            else
              @collection = @current_user.coupons
            end
          end
          def set_coupon
            @coupon = @current_user.coupons.find(params[:id])
          end
        end
      end
    end
  end
end
